From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH v2 net-next] net: phy: Add LED mode driver for Microsemi
Date: Tue, 7 Feb 2017 19:09:10 +0530
Message-ID: <20170207133908.GA29408@microsemi.com>
References: <1485953626-25780-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <6e89a748-f3ca-022f-032f-7fc45c68482d@gmail.com>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <Allan.Nielsen@microsemi.com>, <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0053.outbound.protection.outlook.com ([104.47.32.53]:49616
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753307AbdBGNjV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 08:39:21 -0500
Content-Disposition: inline
In-Reply-To: <6e89a748-f3ca-022f-032f-7fc45c68482d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Thank you for review comments.

On Wed, Feb 01, 2017 at 10:04:08AM -0800, Florian Fainelli wrote:
> EXTERNAL EMAIL
> 
> 
> On 02/01/2017 04:53 AM, Raju Lakkaraju wrote:
> > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> > LED Mode:
> > Microsemi PHY support 2 LEDs (LED[0] and LED[1]) to display different
> > status information that can be selected by setting LED mode.
> 
> Why is this LED selection done through Device Tree/initial configuration
> instead of coming up with a proper LED device registered by the PHY
> which allows you to select exactly how you want the modes to wind-up
> looking like?
> 

I wrote the LED driver similar to "Micrel". Added only LED mode.

> NB: you don't need a cover letter for single patches.
> 
Accepted. I will do.

> >
> > LED Mode parameter (vsc8531, led-0-mode) and (vsc8531, led-1-mode) get from
> > Device Tree.
> >
> > Tested on Beaglebone Black with VSC 8531 PHY.
> >
> > Change set:
> > v0:
> > - Initial version of LED driver for Microsemi PHYs.
> > v1:
> > - Update all review comments given by Andrew.
> > - Add new header file "mscc-phy-vsc8531.h" to define DT macros.
> > - Add error/range check for DT LED mode input
> > v2:
> > - Fixed x86_64 build error.
> >
> > Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> >
> > Raju Lakkaraju (1):
> >   net: phy: Add LED mode driver for Microsemi PHYs.
> >
> >  .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 10 +++
> >  drivers/net/phy/mscc.c                             | 85 +++++++++++++++++++++-
> >  include/dt-bindings/net/mscc-phy-vsc8531.h         | 29 ++++++++
> >  3 files changed, 123 insertions(+), 1 deletion(-)
> >  create mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h
> >
> 
> 
> --
> Florian


---
Thanks,
Raju.
