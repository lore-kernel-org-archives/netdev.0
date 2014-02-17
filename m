From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] caif: delete unnecessary field initialization
Date: Mon, 17 Feb 2014 00:29:37 -0500 (EST)
Message-ID: <20140217.002937.68814317178840128.davem@davemloft.net>
References: <1392449773-23429-3-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1392449773-23429-3-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sat, 15 Feb 2014 08:36:13 +0100

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> On success, the function netdev_alloc_skb initializes the dev field of its
> result to its first argument, so this doesn't have to be done in the
> calling context.
> 
> The semantic patch that fixes this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression skb,privn,e;
> @@
> 
> skb = netdev_alloc_skb(privn,...);
> ... when strict
> (
> -skb->dev = privn;
> |
> ?skb = e
> )
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied to net-next, thanks.
