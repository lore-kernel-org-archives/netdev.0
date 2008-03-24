From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] New driver "sfc" for Solarstorm SFC4000 controller
 (try #8)
Date: Sun, 23 Mar 2008 22:37:36 -0700 (PDT)
Message-ID: <20080323.223736.169461798.davem@davemloft.net>
References: <20080312012102.GB24160@solarflare.com>
	<20080312012437.GF24160@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	jgarzik@pobox.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42753
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752114AbYCXFhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:37:37 -0400
In-Reply-To: <20080312012437.GF24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 12 Mar 2008 01:24:39 +0000

> +static void falcon_setup_rss_indir_table(struct efx_nic *efx)
> +{
> +	int i = 0;
> +	unsigned long offset;
> +	unsigned long flags __attribute__ ((unused));
> +	efx_dword_t dword;

Please delete this unused variable.

> +static int falcon_mdio_read(struct net_device *net_dev, int phy_id, int addr)
> +{
> +	struct efx_nic *efx = (struct efx_nic *)net_dev->priv;
> +	unsigned int phy_addr = phy_id & FALCON_PHY_ID_ID_MASK;
> +	efx_oword_t reg;
> +	int value = -1;
> +	unsigned long flags __attribute__ ((unused));

This one too.

Otherwise mostly looks fine.
