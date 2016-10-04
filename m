From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Tue, 4 Oct 2016 08:54:01 +0200
Message-ID: <20161004065401.GA6097@lunn.ch>
References: <1475479393-24308-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20161004.004859.1105270097322633239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Raju.Lakkaraju@microsemi.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38295 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751884AbcJDGyF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 02:54:05 -0400
Content-Disposition: inline
In-Reply-To: <20161004.004859.1105270097322633239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 04, 2016 at 12:48:59AM -0400, David Miller wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> Date: Mon, 3 Oct 2016 12:53:13 +0530
> 
> > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> > 
> > Edge-rate:
> > As system and networking speeds increase, a signal's output transition,
> > also know as the edge rate or slew rate (V/ns), takes on greater importance
> > because high-speed signals come with a price. That price is an assortment of
> > interference problems like ringing on the line, signal overshoot and
> > undershoot, extended signal settling times, crosstalk noise, transmission
> > line reflections, false signal detection by the receiving device and
> > electromagnetic interference (EMI) -- all of which can negate the potential
> > gains designers are seeking when they try to increase system speeds through
> > the use of higher performance logic devices. The fact is, faster signaling
> > edge rates can cause a higher level of electrical noise or other type of
> > interference that can actually lead to slower line speeds and lower maximum
> > system frequencies. This parameter allow the board designers to change the
> > driving strange, and thereby change the EMI behavioral.
> > 
> > Edge-rate parameters (vddmac, edge-slowdown) get from Device Tree.
> > 
> > Tested on Beaglebone Black with VSC 8531 PHY.
> > 
> > Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Applied, thanks.

Oh dear. It was not ready for acceptance yet. I guess you missed all
the discussion because it was attached to the previous version of the
patch.

Raju you now need to submit fixup patches relative to the version
David has accepted, to fix the issues we were discussing.

      Andrew
