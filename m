From: "Aries Lee" <arieslee@jmicron.com>
Subject: RE: [PATCH 1/1]  PHY configuration for compatible issue
Date: Mon, 21 Nov 2011 10:13:27 +0800
Message-ID: <201111210213.pAL2DRxt013405@jmr105.jmicron.com>
References: <20111119041736.M37290@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'AriesLee'" <AriesLeeILan@gmail.com>
To: "'Guo-Fu Tseng'" <cooldavid@cooldavid.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spamfilter.jmicron.com ([220.130.51.235]:12073 "EHLO
	jmsspam.jmicron.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753943Ab1KUCQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 21:16:57 -0500
In-Reply-To: <20111119041736.M37290@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Yes ~~ that's indeed a good suggestion

-----Original Message-----
From: Guo-Fu Tseng [mailto:cooldavid@cooldavid.org] 
Sent: Saturday, November 19, 2011 12:20 PM
To: Aries Lee; netdev@vger.kernel.org
Cc: 'AriesLee'
Subject: RE: [PATCH 1/1] PHY configuration for compatible issue

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
