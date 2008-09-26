From: Patrick McHardy <kaber@trash.net>
Subject: Re: Bisect'ed BUG in VLAN promisc mode (6c78dcbd47)
Date: Fri, 26 Sep 2008 21:24:02 +0200
Message-ID: <48DD36D2.90103@trash.net>
References: <1222437636.7598.14.camel@localhost.localdomain>	 <48DD0A4F.6020703@trash.net> <1222456933.2381.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46052 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbYIZTYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 15:24:05 -0400
In-Reply-To: <1222456933.2381.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> On Fri, 2008-09-26 at 18:14 +0200, Patrick McHardy wrote:
>> Jesper Dangaard Brouer wrote:
>>> Hi Patrick,
>>>
>>> Bisected me down to one of you changes
>>>  commit 6c78dcbd47a68a
>>>  [VLAN]: Fix promiscous/allmulti synchronization races
>>>
>>> Description:
>>> ------------
>>>  All other VLAN interfaces stop working, if a vlan is taken down
>>>  (ifconfig eth1.1025 down) _while_ there is a tcpdump running on that
>>>  interface.
>>>
>>>  The problem is a result of promisc mode being removed on the
>>>  real-device (eth1), when the vlan interface is taken down.  This
>>>  should not happen as other vlan devices exists that still need
>>>  promisc mode on the real-device (eth1).
>> I'm pretty sure we fixed this already in commit 0ed21b32.
> 
> I think that I have tested including this commit.  The first thing I did
> was to test with latest DaveM net-2.6 git tree.

Let me see if I can reproduce it ...
