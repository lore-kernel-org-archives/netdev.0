From: Patrick McHardy <kaber@trash.net>
Subject: Re: Bisect'ed BUG in VLAN promisc mode (6c78dcbd47)
Date: Fri, 26 Sep 2008 18:14:07 +0200
Message-ID: <48DD0A4F.6020703@trash.net>
References: <1222437636.7598.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41728 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbYIZQOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 12:14:12 -0400
In-Reply-To: <1222437636.7598.14.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> Hi Patrick,
> 
> Bisected me down to one of you changes
>  commit 6c78dcbd47a68a
>  [VLAN]: Fix promiscous/allmulti synchronization races
> 
> Description:
> ------------
>  All other VLAN interfaces stop working, if a vlan is taken down
>  (ifconfig eth1.1025 down) _while_ there is a tcpdump running on that
>  interface.
> 
>  The problem is a result of promisc mode being removed on the
>  real-device (eth1), when the vlan interface is taken down.  This
>  should not happen as other vlan devices exists that still need
>  promisc mode on the real-device (eth1).

I'm pretty sure we fixed this already in commit 0ed21b32.
