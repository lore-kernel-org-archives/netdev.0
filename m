From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH net-next 2/2] net: phy: Add Fast Link Failure - 2 set
 driver for Microsemi PHYs.
Date: Mon, 17 Oct 2016 13:43:14 +0530
Message-ID: <20161017081312.GB2365@microsemi.com>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1476445233-26524-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20161014120228.GF5822@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0045.outbound.protection.outlook.com ([104.47.36.45]:55328
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757820AbcJQIOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 04:14:09 -0400
Content-Disposition: inline
In-Reply-To: <20161014120228.GF5822@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for code review and comments.

On Fri, Oct 14, 2016 at 02:02:28PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> > On Fri, Oct 14, 2016 at 05:10:33PM +0530, Raju Lakkaraju wrote:
> > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> > VSC8531 Fast Link Failure 2 feature enables the PHY to indicate the
> > onset of a potential link failure in < 100 usec for 100BASE-TX
> > operation. FLF2 is supported through the MDINT (active low) pin.
> 
> Is the MDINT pin specific to this feature, or a general interrupt pin?
> 

MDINT pin is general interrupt. MDINT pin share the interrupt with
FLF2 along with another 13 interrupts.

> Device tree is used to describe the hardware. It should not really
> describe software or configuration. But the borders are a bit
> fluffly. Signal edge rates is near to hardware. This is a lot more
> towards configuration. So i'm not sure a device tree property is the
> correct way to describe this.
> 
> This is also a feature i know other PHYs support. The Marvell PHY has
> a "Metro Ethernet" extension which allows it to report link failures
> for 1000BASE-T in 10, 20 or 40ms, instead of the usual 750ms. So we
> need a generic solution other PHYs can implement.
> 
> As with cable testing, i think it should be an ethtool option.

I agree with you.
I thought this is one time initialization either enable or disable.
if customer need this feature, they can enable in DT.
Do you want me to implement through IOCTL instead of Device tree?
Do you have any other suggestions?

> 
>    Andrew

---
Thanks,
Raju.
