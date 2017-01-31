From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/6] drivers: net: xgene-v2: Add base driver
Date: Tue, 31 Jan 2017 21:01:49 +0100
Message-ID: <20170131200149.GM5656@lunn.ch>
References: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
 <1485889401-13909-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51683 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751372AbdAaUBy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 15:01:54 -0500
Content-Disposition: inline
In-Reply-To: <1485889401-13909-5-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	phy_mode = device_get_phy_mode(dev);
> +	if (phy_mode < 0) {
> +		dev_err(dev, "Unable to get phy-connection-type\n");
> +		return phy_mode;
> +	}
> +	pdata->resources.phy_mode = phy_mode;
> +
> +	if (pdata->resources.phy_mode != PHY_INTERFACE_MODE_RGMII) {
> +		dev_err(dev, "Incorrect phy-connection-type specified\n");
> +		return -ENODEV;
> +	}

This seems a bit limiting. What if you need to use:

PHY_INTERFACE_MODE_RGMII_ID,
PHY_INTERFACE_MODE_RGMII_RXID,
PHY_INTERFACE_MODE_RGMII_TXID,

in order to set the RGMII delays.

   Andrew
