From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers/net/defxx.c: use %pMF to show MAC address
Date: Thu, 07 Jan 2010 17:39:10 -0800
Message-ID: <1262914750.10429.88.camel@Joe-Laptop.home>
References: <201001071624.20139.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, macro@linux-mips.org, davem@davemloft.net
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752308Ab0AHBjO@vger.kernel.org>
In-Reply-To: <201001071624.20139.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-01-07 at 16:24 -0700, H Hartley Sweeten wrote:
> Use the %pMF kernel extension to display the MAC address.
> The address will still be displayed in the FDDI Canonical format.

> diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
> index 6a6ea03..e4eac4b 100644
> --- a/drivers/net/defxx.c
> +++ b/drivers/net/defxx.c
> @@ -1052,12 +1052,9 @@ static int __devinit dfx_driver_init(struct net_device *dev,
>  		board_name = "DEFEA";
>  	if (dfx_bus_pci)
>  		board_name = "DEFPA";
> -	pr_info("%s: %s at %saddr = 0x%llx, IRQ = %d, "
> -		"Hardware addr = %02X-%02X-%02X-%02X-%02X-%02X\n",
> +	pr_info("%s: %s at %saddr = 0x%llx, IRQ = %d, Hardware addr = %pMF\n",
>  		print_name, board_name, dfx_use_mmio ? "" : "I/O ",

I believe the output will _now_ be in the canonical form.
Before it wasn't bit reversed.  Now it should be.
