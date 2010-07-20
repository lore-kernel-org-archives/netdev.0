From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] ipv6: Make IP6CB(skb)->nhoff 16-bit.
Date: Mon, 19 Jul 2010 22:01:43 -0700 (PDT)
Message-ID: <20100719.220143.233859017.davem@davemloft.net>
References: <20100715.223011.58409183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752271Ab0GTFB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 01:01:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A6AA224C090
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 22:01:43 -0700 (PDT)
In-Reply-To: <20100715.223011.58409183.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 15 Jul 2010 22:30:11 -0700 (PDT)

> 
> Even with jumbograms I cannot see any way in which we would need
> to records a larger than 65535 valued next-header offset.
> 
> The maximum extension header length is (256 << 3) == 2048.
> There are only a handful of extension headers specified which
> we'd even accept (say 5 or 6), therefore the largest next-header
> offset we'd ever have to contend with is something less than
> say 16k.
> 
> Therefore make it a u16 instead of a u32.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> Can anyone find any holes in this?  I want to do this so we
> can legitimately rip ndisc_nodetype out of struct sk_buff
> and stick it into the IP6CB where it belongs.  Currently
> there isn't enough space, but with this change there will
> be.

No holes claimed by anyone, so... applied :-)
