From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: RE: [PATCH 1/1]  PHY configuration for compatible issue
Date: Sat, 19 Nov 2011 12:19:44 +0800
Message-ID: <20111119041736.M37290@cooldavid.org>
References: <20111117070537.M4900@cooldavid.org> <201111180713.pAI7Df9w013423@jmr105.jmicron.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: "'AriesLee'" <AriesLeeILan@gmail.com>
To: "Aries Lee" <arieslee@jmicron.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:43857 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751744Ab1KSETx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Nov 2011 23:19:53 -0500
In-Reply-To: <201111180713.pAI7Df9w013423@jmr105.jmicron.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Nov 2011 15:13:37 +0800, Aries Lee wrote
> Hi Guo-Fu and All
> 
> 	Because jme_phy_on() and jme_phy_off() just turn on/off the PHY, the
> value of extern register is still the power on default value, not the most
> robust value which we collect in the LAB.
Sure, I got it. That's the point of this patch isn't it? :p
+     /*  Turn PHY off */ 
+     bmcr = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_BMCR); 
+     bmcr |= BMCR_PDOWN; 
+     jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_BMCR, bmcr); 
+     /*  Turn PHY on */ 
+     bmcr = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_BMCR); 
+     bmcr &= ~BMCR_PDOWN; 
+     jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_BMCR, bmcr); 
But what I mean is this part of the code.

Guo-Fu Tseng
