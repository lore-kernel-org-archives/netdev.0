From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Mon, 28 Aug 2017 16:09:27 +0200
Message-ID: <20170828140927.GD10418@lunn.ch>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
 <20170827163122.GG13622@lunn.ch>
 <20170828070232.GA18135@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46232 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751161AbdH1OJb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 10:09:31 -0400
Content-Disposition: inline
In-Reply-To: <20170828070232.GA18135@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I may be confused here, but AFAICT:
> 
> 1) Yes, it has standard layout when accessed over MDIO. 


Section 4.8 of the datasheet says:

	All the registers defined in this section can be also accessed
	via the SPI interface.

Meaning all PHY registers can be access via the SPI interface. So you
should be able to make a standard Linux MDIO bus driver which performs
SPI reads.

    Andrew
