From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] drivers/atm/atmtcp.c: fix error return code
Date: Thu, 07 Aug 2014 16:05:10 -0700 (PDT)
Message-ID: <20140807.160510.734997025610406474.davem@davemloft.net>
References: <1407415749-19978-3-git-send-email-Julia.Lawall@lip6.fr>
	<20140807091012.793ef5c7@thirdoffive.cmf.nrl.navy.mil>
	<alpine.DEB.2.10.1408071530230.2337@hadrien>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: julia.lawall@lip6.fr
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1408071530230.2337@hadrien>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Thu, 7 Aug 2014 15:31:05 +0200 (CEST)

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Convert a zero return value on error to a negative one, as returned
> elsewhere in the function.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> v2; changed error code to -EUNATCH

Applied.
