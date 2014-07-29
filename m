From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/udp_offload: Use IS_ERR_OR_NULL
Date: Tue, 29 Jul 2014 15:32:33 -0700 (PDT)
Message-ID: <20140729.153233.393892187663047923.davem@davemloft.net>
References: <20140727070838.GA4866@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140727070838.GA4866@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Sun, 27 Jul 2014 12:38:38 +0530

> This patch introduces the use of the macro IS_ERR_OR_NULL in place of
> tests for NULL and IS_ERR.
> 
> The following Coccinelle semantic patch was used for making the change:
> 
> @@
> expression e;
> @@
> 
> - e == NULL || IS_ERR(e)
> + IS_ERR_OR_NULL(e)
>  || ...
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
