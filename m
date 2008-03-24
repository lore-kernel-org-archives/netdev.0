From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] New driver "sfc" for Solarstorm SFC4000 controller
 (try #8)
Date: Sun, 23 Mar 2008 22:40:51 -0700 (PDT)
Message-ID: <20080323.224051.180653986.davem@davemloft.net>
References: <20080312012102.GB24160@solarflare.com>
	<20080312012629.GJ24160@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	jgarzik@pobox.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42769
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752315AbYCXFkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:40:52 -0400
In-Reply-To: <20080312012629.GJ24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 12 Mar 2008 01:26:30 +0000

> diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
> new file mode 100644
> index 0000000..4a29613
> --- /dev/null
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

Just put all of these objects on one assignment
line as is common practice.
