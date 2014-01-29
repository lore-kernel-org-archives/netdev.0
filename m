From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: eth: cpsw: Correctly attach to GPIO bitbang MDIO
 driver
Date: Wed, 29 Jan 2014 17:12:31 +0530
Message-ID: <52E8E927.3020801@ti.com>
References: <1390991557-22522-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Lukas Stockmann <lukas.stockmann@siemens.com>
To: Stefan Roese <sr@denx.de>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:40870 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750930AbaA2Lml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jan 2014 06:42:41 -0500
In-Reply-To: <1390991557-22522-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 29 January 2014 04:02 PM, Stefan Roese wrote:
> When the GPIO bitbang MDIO driver is used instead of the Davinci MDIO driver
> we need to configure the phy_id string differently. Otherwise this string
> looks like this "gpio.6" instead of "gpio-0" and the PHY is not found when
> phy_connect() is called.
>
> Signed-off-by: Stefan Roese <sr@denx.de>
> Cc: Lukas Stockmann <lukas.stockmann@siemens.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
