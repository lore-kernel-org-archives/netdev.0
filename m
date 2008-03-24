From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 8/8] New driver "sfc" for Solarstorm SFC4000 controller
	(try #8)
Date: Mon, 24 Mar 2008 04:52:03 -0400
Message-ID: <20080324085202.GA4845@infradead.org>
References: <20080312012102.GB24160@solarflare.com> <20080312012629.GJ24160@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34000 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbYCXIwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 04:52:05 -0400
Content-Disposition: inline
In-Reply-To: <20080312012629.GJ24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +++ b/drivers/net/sfc/Makefile
> @@ -0,0 +1,23 @@
> +
> +# Final objects
> +sfc_o = sfc.o
> +
> +# Constituent objects
> +sfc_elements_o :=
> +sfc_elements_o += efx.o
> +sfc_elements_o += falcon.o
> +sfc_elements_o += tx.o
> +sfc_elements_o += rx.o
> +sfc_elements_o += falcon_xmac.o
> +sfc_elements_o += i2c-direct.o
> +sfc_elements_o += ethtool.o
> +sfc_elements_o += xfp_phy.o
> +sfc_elements_o += mdio_10g.o
> +sfc_elements_o += tenxpress.o
> +sfc_elements_o += boards.o
> +sfc_elements_o += sfe4001.o
> +
> +obj-$(CONFIG_SFC) += $(sfc_o)
> +
> +sfc-objs = $(sfc_elements_o)

Very strange makefile.  This should be:

sfc-y			+= efx.o falcon.o tx.o rx.o falcon_xmac.o \					   i2c-direct.o ethtool.o xfp_phy.o mdio_10g.o \
			   tenxpress.o boards.o sfe4001.o

obj-$(CONFIG_SFC)	+= sfc.o
