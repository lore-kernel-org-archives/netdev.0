From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v2] net: phy: add driver for aquantia phy
Date: Thu, 30 Jul 2015 15:55:01 -0700 (PDT)
Message-ID: <20150730.155501.1888422787034100150.davem@davemloft.net>
References: <1438229835-44865-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541AbbG3WzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 18:55:04 -0400
In-Reply-To: <1438229835-44865-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Thu, 30 Jul 2015 12:17:15 +0800

> +static int aquantia_soft_reset(struct phy_device *phydev)
> +{
> +	return 0;
> +}
> +
> +static int aquantia_config_init(struct phy_device *phydev)
> +{
> +	return 0;
> +}

You shouldn't need to implement these methods at all, just
leave them NULL in the driver struct.

The only thing implementing them as nop routines like this does is
make the PHY fixups get scanned.  And I don't think there are any
for this device.
