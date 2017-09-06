From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 2/4] lan78xx: Add fixed_phy device support for
 LAN7801 device
Date: Wed, 6 Sep 2017 16:02:33 +0200
Message-ID: <20170906140233.GC11864@lunn.ch>
References: <CE371C1263339941885964188A0225FA333381@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org
To: Nisar.Sayed@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58688 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932284AbdIFOCg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 10:02:36 -0400
Content-Disposition: inline
In-Reply-To: <CE371C1263339941885964188A0225FA333381@CHN-SV-EXMX03.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 06, 2017 at 10:51:44AM +0000, Nisar.Sayed@microchip.com wrote:
> From: Nisar Sayed <Nisar.Sayed@microchip.com>
> 
> Add fixed_phy device support for LAN7801 device
> 
> When LAN7801 device connected to PHY Device which does not have
> MDIO/MDC access, fixex_phy device will be added.

Please try to find a way to do this without all the #ifdefs. They can
be acceptable in header files, but should be avoided in .c files.

   Andrew
