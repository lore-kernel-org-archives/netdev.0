From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: phy: Add Speed downshift set driver
 for Microsemi PHYs.
Date: Fri, 14 Oct 2016 14:12:32 +0200
Message-ID: <20161014121232.GH5822@lunn.ch>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1476445233-26524-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        f.fainelli@gmail.com, Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45376 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753093AbcJNMMe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 08:12:34 -0400
Content-Disposition: inline
In-Reply-To: <1476445233-26524-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2016 at 05:10:32PM +0530, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> For operation in cabling environments that are incompatible with
> 1000BAST-T, VSC8531 device provides an automatic link speed
> downshift operation. When enabled, the device automatically changes
> its 1000BAST-T auto-negotiation to the next slower speed after
> a configured number of failed attempts at 1000BAST-T.
> This feature is useful in setting up in networks using older cable
> installations that include only pairs A and B, and not pairs C and D.

Any reason not to just turn this on by default when auto-neg is
enabled?

	Andrew
