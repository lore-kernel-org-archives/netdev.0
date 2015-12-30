From: Shaohui Xie <shaohui.xie@nxp.com>
Subject: RE: [PATCHv3 net-next 2/3] phy: marvell: Add ethtool statistics
 counters
Date: Wed, 30 Dec 2015 04:24:40 +0000
Message-ID: <VI1PR04MB1664FF303D53D9472E36452BE8FD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
References: <1451418684-9238-1-git-send-email-andrew@lunn.ch>
 <1451418684-9238-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	"Florian Fainelli" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0053.outbound.protection.outlook.com ([157.56.112.53]:44570
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753247AbbL3EYr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 23:24:47 -0500
In-Reply-To: <1451418684-9238-3-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCHv3 net-next 2/3] phy: marvell: Add ethtool statistics counters
> +static int marvell_probe(struct phy_device *phydev) {
> +	struct marvell_priv *priv;
> +
> +	priv = devm_kzalloc(&phydev->dev, sizeof(*priv), GFP_KERNEL);
> +	if (!priv)
> +		return -ENOMEM;
> +
> +	phydev->priv = priv;
> +
> +	return 0;
> +}
> +
[S.H] Is a remove() function needed to free the memory?

Thanks,
Shaohui
