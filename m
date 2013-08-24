From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [RFC] b44: use phylib
Date: Sat, 24 Aug 2013 16:32:48 +0200
Message-ID: <5218C410.7020505@hauke-m.de>
References: <1377298608-18016-1-git-send-email-hauke@hauke-m.de> <1377299409.2816.19.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Florian Fainelli <florian@openwrt.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:53004 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754578Ab3HXOcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Aug 2013 10:32:55 -0400
In-Reply-To: <1377299409.2816.19.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2013 01:10 AM, Joe Perches wrote:
> On Sat, 2013-08-24 at 00:56 +0200, Hauke Mehrtens wrote:
>> This splits the driver into the mac and a phy driver. On routers where
>> this driver is used we have a switch which implements a phy and can be
>> controlled by a phy driver.
> 
> trivial comments only...

I will extend this.

>> diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
> []
>> +static void b44_adjust_link(struct net_device *dev)
>> +{
>> +	struct b44 *bp = netdev_priv(dev);
>> +	struct phy_device *phydev = bp->phydev;
>> +	int status_changed = 0;
> 
> bool?

Thanks, I will change this.

>> +static int b44_mii_probe(struct net_device *dev)
>> +{
> []
>> +	if (IS_ERR(phydev)) {
>> +		netdev_err(dev, "could not attach PHY: %s", phy_id);
> 
> missing newline?

Fixed.
