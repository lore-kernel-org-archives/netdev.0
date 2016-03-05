From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] rose_route_frame() NULL pointer dereference kernel
 panic
Date: Sat, 05 Mar 2016 11:22:26 -0500 (EST)
Message-ID: <20160305.112226.2192524821017178121.davem@davemloft.net>
References: <56D5FD7A.5080104@free.fr>
	<20160303.170253.1102862150292919836.davem@davemloft.net>
	<56DAFC1A.5000408@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org
To: f6bvp@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcCEQW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 11:22:28 -0500
In-Reply-To: <56DAFC1A.5000408@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: f6bvp <f6bvp@free.fr>
Date: Sat, 5 Mar 2016 16:32:42 +0100

> I understand I did not explain clearly or completely things.
> 
> I agree that each time patched rose_xmit() is calling
> rose_route_frame() it will
> get a 0 return.
> And I think this is what was intended by the author of rose_xmit().

If that's what he intended he would have implemented the entirety of
rose_xmit() as "kfree_skb(skb)".  But that's obviously not the case.

The author meant the packet to be sent in some way, perhaps using a
default path or something like that.

So please stop telling me over and over again that this function
is meant to simply drop all packets, it's not true.
