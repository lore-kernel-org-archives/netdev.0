From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/nxp/lpc_eth: use devm_ functions
Date: Tue, 17 Jun 2014 15:31:14 -0700 (PDT)
Message-ID: <20140617.153114.745988923921147057.davem@davemloft.net>
References: <20140613180356.GA8582@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140613180356.GA8582@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 13 Jun 2014 23:33:56 +0530

> The various devm_ functions allocate memory that is released when a
> driver detaches. This patch uses dmam_alloc_coherent, devm_ioremap
> devm_clk_get etc. for data that is allocated in the probe function of
> platform device and is only freed in the remove function. The
> corresponding free functions are removed and many labels are done
> away with.
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>
> ---
> v2: undo use of devm_request_irq
> Not compile tested

This doesn't apply cleanly to any of my trees.
