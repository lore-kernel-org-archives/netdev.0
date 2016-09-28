From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH v3 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Wed, 28 Sep 2016 16:39:54 +0530
Message-ID: <20160928110953.GA22063@microsemi.com>
References: <1474984075-12312-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160927141633.GJ28432@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0078.outbound.protection.outlook.com ([104.47.33.78]:59501
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752630AbcI1LKe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 07:10:34 -0400
Content-Disposition: inline
In-Reply-To: <20160927141633.GJ28432@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for review and valuable comments.

Thanks,
Raju.
On Tue, Sep 27, 2016 at 04:16:33PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> > index 0000000..7ba3855
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> > @@ -0,0 +1,61 @@
> > +* Microsemi - vsc8531 Giga bit ethernet phy
> > +
> > +Required properties:
> > +- compatible : Should contain phy id as "ethernet-phy-idAAAA.BBBB"
> > +               If the phy's identifier is known then the list may contain an entry
> > +               of the form: "ethernet-phy-idAAAA.BBBB" where
> > +               AAAA - The value of the 16 bit Phy Identifier 1 register as
> > +                      4 hex digits. This is the chip vendor OUI bits 3:18
> > +               BBBB - The value of the 16 bit Phy Identifier 2 register as
> > +                      4 hex digits. This is the chip vendor OUI bits 19:24,
> > +                      followed by 10 bits of a vendor specific ID.
> > +- reg                : The ID number for the phy, usually a small integer
> 
> Please don't copy phy.txt. Just refer to it. Use text like:
> 
> The PHY device uses the binding described in
> Documentation/devicetree/bindings/net/phy.txt
> 
> It may additionally have the following properties
> 

Accepted. 

> > +Optional properties:
> > +- vsc8531,edge-rate  : Edge rate sets the drive strength of the MAC
> > +                       interface output signals.  Changing the drive
> > +                       strength will affect the edge rate of the output
> > +                       signal.
> 
> Are we specifying a rate or a strength? It is called edge-rate, so it
> expect it to be a rate, mV/pS or something similar.
> 

Accepted.

>        Andrew
