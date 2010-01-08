From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ep93xx_eth.c general cleanup
Date: Fri, 08 Jan 2010 00:53:14 -0800 (PST)
Message-ID: <20100108.005314.32731548.davem@davemloft.net>
References: <201001051405.31782.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	buytenh@wantstofly.org
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752251Ab0AHIxM@vger.kernel.org>
In-Reply-To: <201001051405.31782.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Tue, 5 Jan 2010 14:05:31 -0700

> General cleanup of the ep93xx_eth driver.
> 
> 1) Use pr_fmt() to prefix the module name and __func__ to the error 
>    messages.
> 2) <linux/io.h> instead of <asm/io.h>
> 3) <mach/hardware.h> instead of <mach/ep93xx-regs.h> and <mach/platform.h>
> 4) Move the ep93xx_mdio_read (and ep93xx_mdio_write) function to eliminate
>    the function prototype.
> 5) Change all the printk(<level> messages to pr_<level> and remove the 
>    __func__ argument.
> 6) Use platform_get_{resource/irq} to get the platform resources and add
>    an error check.
> 7) Use resource_size() for request_mem_region() and ioremap().
> 8) Use %pM to print the MAC address at the end of the probe.
> 9) Use dev->dev_addr not data->dev_addr for the MAC argument because a
>    random address could be used if the platform does not supply one.
> 
> The message at the end of the probe is left as a printk since it displays
> cleaner without the function name that would be displayed with pr_info().
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Acked-by: Lennert Buytenhek <kernel@wantstofly.org>

Applied, thanks.
