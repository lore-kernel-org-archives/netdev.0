From: David Miller <davem@davemloft.net>
Subject: Re: Netlink mmap tx security?
Date: Wed, 15 Oct 2014 19:57:37 -0400 (EDT)
Message-ID: <20141015.195737.1429281929513331763.davem@davemloft.net>
References: <CALCETrWDSG2EhxBnM8Jm55Ov8PYQ_w3Wf88SKYOB1q1WgRpbEw@mail.gmail.com>
	<20141014.220111.179628329028952302.davem@davemloft.net>
	<543F0712.8080503@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, torvalds@linux-foundation.org,
	kaber@trash.net, netdev@vger.kernel.org, tgraf@suug.ch
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaJOX5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 19:57:41 -0400
In-Reply-To: <543F0712.8080503@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 16 Oct 2014 01:45:22 +0200

> On 10/15/2014 04:01 AM, David Miller wrote:
>> From: Andy Lutomirski <luto@amacapital.net>
>> Date: Tue, 14 Oct 2014 15:16:46 -0700
>>
>>> It's at least remotely possible that there's something that assumes
>>> that assumes that the availability of NETLINK_RX_RING implies
>>> NETLINK_TX_RING, which would be unfortunate.
>>
>> I already found one such case, nlmon :-/
> 
> Hmm, can you elaborate? I currently don't think that nlmon cares
> actually.

nlmon cares, openvswitch cares, etc:

http://openvswitch.org/pipermail/dev/2013-December/034496.html
