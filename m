From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc91x: constify dev_pm_ops structures.
Date: Thu, 29 Jun 2017 15:49:45 -0400 (EDT)
Message-ID: <20170629.154945.1255625119131638079.davem@davemloft.net>
References: <f588f3a825cfb2bbdee2f53d9b7d470b0db8f968.1498715281.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmk+kernel@armlinux.org.uk, jeremy.linton@arm.com,
        jarod@redhat.com, nico@fluxnic.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f588f3a825cfb2bbdee2f53d9b7d470b0db8f968.1498715281.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Thu, 29 Jun 2017 11:21:00 +0530

> dev_pm_ops are not supposed to change at runtime. All functions
> working with dev_pm_ops provided by <linux/device.h> work with const
> dev_pm_ops. So mark the non-const structs as const.
> 
> File size before:
>    text	   data	    bss	    dec	    hex	filename
>   18709	    401	      0	  19110	   4aa6	drivers/net/ethernet/smsc/smc91x.o
> 
> File size After adding 'const':
>    text	   data	    bss	    dec	    hex	filename
>   18901	    201	      0	  19102	   4a9e	drivers/net/ethernet/smsc/smc91x.o
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.
