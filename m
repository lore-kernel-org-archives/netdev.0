From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v6 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Tue, 4 Oct 2016 13:51:32 +0200
Message-ID: <20161004115132.GG11677@lunn.ch>
References: <1475581272-12093-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        f.fainelli@gmail.com, Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38500 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751549AbcJDLvg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 07:51:36 -0400
Content-Disposition: inline
In-Reply-To: <1475581272-12093-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 04, 2016 at 05:11:12PM +0530, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Edge-rate:
> As system and networking speeds increase, a signal's output transition,
> also know as the edge rate or slew rate (V/ns), takes on greater importance
> because high-speed signals come with a price. That price is an assortment of
> interference problems like ringing on the line, signal overshoot and
> undershoot, extended signal settling times, crosstalk noise, transmission
> line reflections, false signal detection by the receiving device and
> electromagnetic interference (EMI) -- all of which can negate the potential
> gains designers are seeking when they try to increase system speeds through
> the use of higher performance logic devices. The fact is, faster signaling
> edge rates can cause a higher level of electrical noise or other type of
> interference that can actually lead to slower line speeds and lower maximum
> system frequencies. This parameter allow the board designers to change the
> driving strange, and thereby change the EMI behavioral.
> 
> Edge-rate parameters (vddmac, edge-slowdown) get from Device Tree.
> 
> Tested on Beaglebone Black with VSC 8531 PHY.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> ---
> All the review comments updated and resending for review.
> 
> Change set:
> v1:
> - Initial version of Edge-rate driver add by using IOCTL.
> v2:
> - Changed edge-rate parameter to Device Tree with magic number.
> v3:
> - Added Device Tree documentati0n and edge-rate parameter table.
>   Added probe function initialize the vsc8531 private data structure.
> v4:
> - As per review comment, Device Tree parameters (vddmac, edge-slowdown)
>   added.
> v5:
> - As per review comment, Device Tree Document parameters (vddmac, 
>   edge-slowdown) real numbers added. Table number changed from 5 to 1.
> v6:
> - As per review comment, Removed Device Tree header file. Removed MACROs
>   and add ARRAYSIZE 

But you ignored my request to make the table values positive, and to
enforce an exact match in the table.

NACK

	Andrew
