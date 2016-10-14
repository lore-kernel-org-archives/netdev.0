From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] net: phy: Add Fast Link Failure - 2 set
 driver for Microsemi PHYs.
Date: Fri, 14 Oct 2016 14:02:28 +0200
Message-ID: <20161014120228.GF5822@lunn.ch>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1476445233-26524-3-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        f.fainelli@gmail.com, Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45365 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754768AbcJNMCa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 08:02:30 -0400
Content-Disposition: inline
In-Reply-To: <1476445233-26524-3-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Fri, Oct 14, 2016 at 05:10:33PM +0530, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> VSC8531 Fast Link Failure 2 feature enables the PHY to indicate the
> onset of a potential link failure in < 100 usec for 100BASE-TX
> operation. FLF2 is supported through the MDINT (active low) pin.

Is the MDINT pin specific to this feature, or a general interrupt pin?

Device tree is used to describe the hardware. It should not really
describe software or configuration. But the borders are a bit
fluffly. Signal edge rates is near to hardware. This is a lot more
towards configuration. So i'm not sure a device tree property is the
correct way to describe this.

This is also a feature i know other PHYs support. The Marvell PHY has
a "Metro Ethernet" extension which allows it to report link failures
for 1000BASE-T in 10, 20 or 40ms, instead of the usual 750ms. So we
need a generic solution other PHYs can implement.

As with cable testing, i think it should be an ethtool option.

   Andrew
