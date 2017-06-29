From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: freescale: gianfar : constify dev_pm_ops
 structures.
Date: Thu, 29 Jun 2017 15:49:50 -0400 (EDT)
Message-ID: <20170629.154950.722057525346376563.davem@davemloft.net>
References: <8a8554d003a6e7bb2435d55258a9120eb5822a82.1498715654.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8a8554d003a6e7bb2435d55258a9120eb5822a82.1498715654.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Thu, 29 Jun 2017 11:26:06 +0530

> dev_pm_ops are not supposed to change at runtime. All functions
> working with dev_pm_ops provided by <linux/device.h> work with const
> dev_pm_ops. So mark the non-const structs as const.
> 
> File size before:
>    text	   data	    bss	    dec	    hex	filename
>   19057	    392	      0	  19449	   4bf9	drivers/net/ethernet/freescale/gianfar.o
> 
> File size After adding 'const':
>    text	   data	    bss	    dec	    hex	filename
>   19249	    192	      0	  19441	   4bf1	drivers/net/ethernet/freescale/gianfar.o
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.
