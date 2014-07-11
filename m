From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Use BUG_ON
Date: Fri, 11 Jul 2014 15:07:01 -0700 (PDT)
Message-ID: <20140711.150701.565471840751692846.davem@davemloft.net>
References: <20140711202538.GA3766@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140711202538.GA3766@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Sat, 12 Jul 2014 01:55:38 +0530

> The semantic patch that makes the transformation is as follows:
> 
> // <smpl>
> @@ expression e; @@
> -if (e) BUG();
> +BUG_ON(e);
> // </smpl>
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
