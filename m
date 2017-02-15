From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 2/2] net: emac: add support for device-tree based PHY
 discovery and setup
Date: Wed, 15 Feb 2017 15:23:08 +0100
Message-ID: <20170215142308.GB10670@lunn.ch>
References: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com>
 <d696cd93-120d-e23f-3cce-5c3b64c7dc31@gmail.com>
 <2122984.F6mzWerJKz@debian64>
 <2409103.Lage0nq55N@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        Christian Lamparter <chunkeey@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>,
        vivien.didelot@savoirfairelinux.com
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40488 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750760AbdBOOXN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 09:23:13 -0500
Content-Disposition: inline
In-Reply-To: <2409103.Lage0nq55N@debian64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > Is the PHY just powered down by chance (BMCR_PWRDN set?) and resetting
> > > it implicitly clears the power down that seems to be what is going on.
> > 
> > Yes, the PHY is just in the BMCR_PDOWN state. I can do the same
> > on the WNDR4700, by messing with u-boot:

Hi Christian

What happens if you list the PHYs in the device tree, with their PHY
ID. That should avoid it looking for the ID and getting 0xffff
back. It should just probe the correct PHY driver. If the first thing
the drivers probe function does it reset the power down bit, it might
work.

	Andrew
