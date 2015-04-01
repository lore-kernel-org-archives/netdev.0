From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: enable MoCA link state change
 detection
Date: Tue, 31 Mar 2015 21:00:28 -0400 (EDT)
Message-ID: <20150331.210028.1632809919741182405.davem@davemloft.net>
References: <20150331220008.B9C2022023D@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52362 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbbDABAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 21:00:32 -0400
In-Reply-To: <20150331220008.B9C2022023D@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Tue, 31 Mar 2015 15:00:08 -0700 (PDT)

> @@ -513,6 +522,13 @@ static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
>  			dev_err(kdev, "failed to register fixed PHY device\n");
>  			return -ENODEV;
>  		}
> +
> +		if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET) {
> +			ret = fixed_phy_set_link_update(phydev,
> +						bcmgenet_fixed_phy_link_update);

This is not indented correctly.

When a function call or declaration or definition spans multiple lines,
arguments on the second and subsequent lines must be indented exactly
to the first column after the openning parenthesis on the first line.

If you are strictly using TAB characters, it is exceedingly likely
that you are indenting these lines incorrectly.  You must use the
appropriate number of TAB, then SPACE characters necessary to reach
the correct column.
