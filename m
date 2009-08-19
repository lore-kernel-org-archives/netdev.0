From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: fix ks8851 build errors
Date: Tue, 18 Aug 2009 20:12:00 -0700 (PDT)
Message-ID: <20090818.201200.69809801.davem@davemloft.net>
References: <20090818184215.fdf1c7ae.sfr@canb.auug.org.au>
	<20090818152705.64557a0b.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090818152705.64557a0b.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 18 Aug 2009 15:27:05 -0700

> --- linux-next-20090818.orig/drivers/net/Kconfig
> +++ linux-next-20090818/drivers/net/Kconfig
> @@ -1733,6 +1733,8 @@ config KS8851
>         tristate "Micrel KS8851 SPI"
>         depends on SPI
>         select MII
> +	select CRC32
> +	select BITREVERSE
>         help
>           SPI driver for Micrel KS8851 SPI attached network chip.
>  

CRC32 alone is sufficient, because it, in turn, selects BITREVERSE

When you resubmit with this simplification, I'll apply the
patch to net-2.6 since the problem exists in Linus's tree
too, not just -next.
