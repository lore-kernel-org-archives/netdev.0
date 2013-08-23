From: Joe Perches <joe@perches.com>
Subject: Re: [RFC] b44: use phylib
Date: Fri, 23 Aug 2013 16:10:09 -0700
Message-ID: <1377299409.2816.19.camel@joe-AO722>
References: <1377298608-18016-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Florian Fainelli <florian@openwrt.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52294 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754135Ab3HWXKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 19:10:10 -0400
In-Reply-To: <1377298608-18016-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-24 at 00:56 +0200, Hauke Mehrtens wrote:
> This splits the driver into the mac and a phy driver. On routers where
> this driver is used we have a switch which implements a phy and can be
> controlled by a phy driver.

trivial comments only...

> diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
[]
> +static void b44_adjust_link(struct net_device *dev)
> +{
> +	struct b44 *bp = netdev_priv(dev);
> +	struct phy_device *phydev = bp->phydev;
> +	int status_changed = 0;

bool?

> +static int b44_mii_probe(struct net_device *dev)
> +{
[]
> +	if (IS_ERR(phydev)) {
> +		netdev_err(dev, "could not attach PHY: %s", phy_id);

missing newline?
