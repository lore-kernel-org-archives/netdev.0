From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: bcm_sf2: Register our slave MDIO bus
Date: Tue, 07 Jun 2016 09:23:22 -0400
Message-ID: <87y46h875h.fsf@ketchup.mtl.sfl>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com> <1465254895-11152-6-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemlof.net, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41741 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712AbcFGNX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 09:23:26 -0400
In-Reply-To: <1465254895-11152-6-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> +static int bcm_sf2_mdio_register(struct dsa_switch *ds)
> +{
> +	struct bcm_sf2_priv *priv = ds_to_priv(ds);
> +	struct device_node *dn;
> +	static int index;
> +	int err;
> +
> +	/* Find our integratd MDIO bus node */

                    integrated

(only if you need to respin a v3.)

Otherwise,

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
