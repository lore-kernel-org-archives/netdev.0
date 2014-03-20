From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V8 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Thu, 20 Mar 2014 14:44:51 -0700
Message-ID: <000001cf4485$a17f3000$e47d9000$@samsung.com>
References: <012d01cf4461$77a062f0$66e128d0$@samsung.com>
 <20140320.173338.1960242211982744557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org, ks.giri@samsung.com,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ilho215.lee@samsung.com
To: 'David Miller' <davem@davemloft.net>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <20140320.173338.1960242211982744557.davem@davemloft.net>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David Miller <davem@davemloft.net> :
> From: Byungho An <bh74.an@samsung.com>
> Date: Thu, 20 Mar 2014 10:25:59 -0700
> 
> > +config NET_VENDOR_SAMSUNG
> > +	bool "Samsung Ethernet device"
> > +	default y
> > +	depends on HAS_IOMEM && HAS_DMA
> > +	select PHYLIB
> > +	select CRC32
> > +	select PTP_1588_CLOCK
> > +	---help---
> > +	  This is the driver for the SXGBE 10G Ethernet IP block found on
Samsung
> > +	  platforms.
> 
> The vendor sub-section does not necessarily need these select and depends
statements.
> 
> These should be put only in the individual driver entries.
OK.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More
> majordomo info at  http://vger.kernel.org/majordomo-info.html
