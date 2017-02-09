From: maowenan <maowenan@huawei.com>
Subject: RE: [net] net: phy: Fix lack of reference count on PHY driver
Date: Thu, 9 Feb 2017 01:01:37 +0000
Message-ID: <F95AC9340317A84688A5F0DF0246F3F201EDA744@szxemi502-mbx.china.huawei.com>
References: <20170201024643.2050-1-f.fainelli@gmail.com>
 <87d96521-9d1f-f8e3-cea4-155b7522107e@arm.com>
 <20170208162332.GA13281@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "rmk+kernel@armlinux.org.uk" <rmk+kernel@armlinux.org.uk>,
        Catalin Marinas <Catalin.Marinas@arm.com>,
        Dan Carpenter <dan.carpenter@oracle.com>
To: Andrew Lunn <andrew@lunn.ch>, Robin Murphy <robin.murphy@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:32061 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbdBIBGj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 20:06:39 -0500
In-Reply-To: <20170208162332.GA13281@lunn.ch>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Thursday, February 09, 2017 12:24 AM
> To: Robin Murphy
> Cc: Florian Fainelli; netdev@vger.kernel.org; davem@davemloft.net;
> rmk+kernel@armlinux.org.uk; maowenan; Catalin Marinas
> Subject: Re: [net] net: phy: Fix lack of reference count on PHY driver
> 
> On Wed, Feb 08, 2017 at 04:03:43PM +0000, Robin Murphy wrote:
> > Hi all,
> >
> > We're seeing a new boot-time crash[1] on SMSC911x hardware from this
> > patch in today's HEAD (as cafe8df8b9bc)...
> 
> Hi Robin
> 
> Thank for the report. See the discussion on netdev under the subject "Kernel
> crashes in phy_attach_direct()"
> 
> Andrew


There is bug report from Dan Carpenter(dan.carpenter@oracle.com) who ran static analysis to find this issue. Thanks a lot.
[bug report] net: phy: Fix lack of reference count on PHY driver
