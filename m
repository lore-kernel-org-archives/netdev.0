From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][2.6] e100_phy.c uses free'd .text after init
Date: Sun, 30 Nov 2003 14:08:24 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3FCA4028.7050201@pobox.com>
References: <Pine.LNX.4.58.0311290033120.1674@montezuma.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Zwane Mwaikambo <zwane@arm.linux.org.uk>
In-Reply-To: <Pine.LNX.4.58.0311290033120.1674@montezuma.fsmlabs.com>
List-Id: netdev.vger.kernel.org

Zwane Mwaikambo wrote:
> diff -u -p -B -r1.1.1.1 e100_phy.c
> --- linux-2.6.0-test11/drivers/net/e100/e100_phy.c	28 Nov 2003 18:03:05 -0000	1.1.1.1
> +++ linux-2.6.0-test11/drivers/net/e100/e100_phy.c	29 Nov 2003 05:39:53 -0000
> @@ -132,7 +132,7 @@ e100_mdi_read(struct e100_private *bdp,
>  	}
>  }
> 
> -static unsigned char __devinit
> +static unsigned char
>  e100_phy_valid(struct e100_private *bdp, unsigned int phy_address)
>  {
>  	u16 ctrl_reg, stat_reg;
> @@ -150,7 +150,7 @@ e100_phy_valid(struct e100_private *bdp,
>  	return true;
>  }
> 
> -static void __devinit
> +static void
>  e100_phy_address_detect(struct e100_private *bdp)
>  {
>  	unsigned int addr;


I should probably move that patch from net-drivers-2.5-exp to mainline, 
it sounds like...

	Jeff
