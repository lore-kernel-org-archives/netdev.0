From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/5] phy: micrel: add Microchip KSZ 9477 Switch
 PHY support
Date: Mon, 8 May 2017 02:12:07 +0200
Message-ID: <20170508001207.GE27709@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40A5BFF6@CHN-SV-EXMX02.mchp-main.com>
 <20170506035021.GB14749@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40A5C2CA@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52488 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751141AbdEHAMN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 7 May 2017 20:12:13 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A5C2CA@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 07, 2017 at 01:02:31AM +0000, Woojung.Huh@microchip.com wrote:
> >> +}, {
> >> +     .phy_id         = PHY_ID_KSZ9477,
> >> +     .phy_id_mask    = MICREL_PHY_ID_MASK,
> >> +     .name           = "Microchip KSZ9477",
> >> +     .features       = PHY_GBIT_FEATURES,
> >> +     .flags          = PHY_HAS_MAGICANEG,
> >
> >Is this magic still used anywhere? I could not find anything.
> >
> Hi Andrew,
> 
> Really no usage in define and flags.
> Will double check and remove it.

Hi Woojung

I just created a patch to remove PHY_HAS_MAGICANEG from the kernel.
Once net-next has reopened when the merge window closes, i will submit
it. So please don't add it here.

    Thanks
	Andrew
