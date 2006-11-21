From: Andrew Morton <akpm@osdl.org>
Subject: Re: [-mm patch] make net/core/skbuff.c:skb_over_panic() static
Date: Mon, 20 Nov 2006 17:37:16 -0800
Message-ID: <20061120173716.10357a90.akpm@osdl.org>
References: <20061114014125.dd315fff.akpm@osdl.org>
	<20061117170205.GE31879@stusta.de>
	<20061120.195556.23029046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:19653 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030644AbWKUBkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 20:40:31 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061120.195556.23029046.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Nov 2006 19:55:56 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Adrian Bunk <bunk@stusta.de>
> Date: Fri, 17 Nov 2006 18:02:05 +0100
> 
> > skb_over_panic() can now become static.
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> Applied to net-2.6.20, thanks Adrian.

Adrian's patch is only applicable if my net-uninline-skb_put.patch is also
applied.

I'm not sure what to do with net-uninline-skb_put.patch.  It's a good patch
if all that deudgging stuff is present in skb_put(), but it's a bad patch
if it isn't present.  But it _is_ present.
