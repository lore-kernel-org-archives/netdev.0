From: <Nisar.Sayed@microchip.com>
Subject: RE: [PATCH net 2/4] lan78xx: Add fixed_phy device support for
 LAN7801 device
Date: Wed, 6 Sep 2017 17:34:54 +0000
Message-ID: <CE371C1263339941885964188A0225FA3335C5@CHN-SV-EXMX03.mchp-main.com>
References: <CE371C1263339941885964188A0225FA333381@CHN-SV-EXMX03.mchp-main.com>
 <20170906140233.GC11864@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>,
        <netdev@vger.kernel.org>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa4.microchip.iphmx.com ([68.232.154.123]:38093 "EHLO
        esa4.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751163AbdIFRfk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 13:35:40 -0400
In-Reply-To: <20170906140233.GC11864@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Andrew, will try to change as suggested.

> On Wed, Sep 06, 2017 at 10:51:44AM +0000, Nisar.Sayed@microchip.com
> wrote:
> > From: Nisar Sayed <Nisar.Sayed@microchip.com>
> >
> > Add fixed_phy device support for LAN7801 device
> >
> > When LAN7801 device connected to PHY Device which does not have
> > MDIO/MDC access, fixex_phy device will be added.
> 
> Please try to find a way to do this without all the #ifdefs. They can be
> acceptable in header files, but should be avoided in .c files.
> 
>    Andrew
