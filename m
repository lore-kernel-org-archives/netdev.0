From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] vti6: delete unneeded call to netdev_priv
Date: Thu, 15 May 2014 16:58:20 -0400 (EDT)
Message-ID: <20140515.165820.1971129599767939900.davem@davemloft.net>
References: <1400125401-15512-4-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, kernel-janitors@vger.kernel.org,
	herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400125401-15512-4-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Thu, 15 May 2014 05:43:21 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Netdev_priv is an accessor function, and has no purpose if its result is
> not used.
> 
> A simplified version of the semantic match that fixes this problem is as
> follows: (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@ local idexpression x; @@
> -x = netdev_priv(...);
> ... when != x
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
