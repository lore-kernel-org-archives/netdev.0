From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/rds: Use AF_INET for sin_family field
Date: Wed, 05 Aug 2009 20:30:43 -0700 (PDT)
Message-ID: <20090805.203043.70203213.davem@davemloft.net>
References: <Pine.LNX.4.64.0908051434110.20453@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754026AbZHFDag@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0908051434110.20453@pc-004.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Wed, 5 Aug 2009 14:34:34 +0200 (CEST)

> Elsewhere the sin_family field holds a value with a name of the form
> AF_..., so it seems reasonable to do so here as well.  Also the values of
> PF_INET and AF_INET are the same.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
 ..
> Signed-off-by: Julia Lawall <julia@diku.dk>

This is obvious enough that I've just tossed it into net-next-2.6

Thanks!
