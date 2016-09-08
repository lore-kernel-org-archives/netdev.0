From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 0/2] net: phy: Add Edge-rate, MAC-IF driver
 for Microsemi PHYs
Date: Thu, 8 Sep 2016 14:59:58 +0200
Message-ID: <20160908125958.GF26445@lunn.ch>
References: <20160824125934.GC13406@lunn.ch>
 <1473326242-4198-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38812 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934510AbcIHNAA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 09:00:00 -0400
Content-Disposition: inline
In-Reply-To: <1473326242-4198-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2016 at 02:47:20PM +0530, Raju Lakkaraju wrote:
> Patch 1/2:
> 
> This is Edge rate control feature.
> As system and networking speeds increase, a signal's output transition,
> also know as the edge rate or slew rate (V/ns), takes on greater importance
> because high-speed signals come with a price. That price is an assortment of
> interference problems like ringing on the line, signal overshoot and
> undershoot, extended signal settling times, crosstalk noise, transmission line
> reflections, false signal detection by the receiving device and electromagnetic
> interference (EMI) -- all of which can negate the potential gains designers are
> seeking when they try to increase system speeds through the use of higher
> performance logic devices. The fact is, faster signaling edge rates can cause
> a higher level of electrical noise or other type of interference that can
> actually lead to slower line speeds and lower maximum system frequencies.
> 
> Microsemi PHY have the provision to configure the edge rate. Edge-rate function
> program the right value based on Device Tree configuration.
> 
> Tested on Beaglebone Black with VSC 8531 PHY.
> 
> Patch 2/2:
> 
> This is MAC interface feature.
> Microsemi PHY can support RGMII, RMII or GMII/MII interface between MAC and PHY.
> MAC-IF function program the right value based on Device tree configuration.

Hi Raju

In future, please start a new thread for a new version of the
patchset.

	Thanks
		Andrew
