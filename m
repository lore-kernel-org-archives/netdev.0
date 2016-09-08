From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH 3/4] net: phy: Add read driver for Microsemi PHYs.
Date: Thu, 8 Sep 2016 15:12:12 +0530
Message-ID: <20160908094211.GA4281@microsemi.com>
References: <646450A91FAED74E85C6E9C4D6E936A1453366A5@avsrvexchmbx1.microsemi.net>
 <20160824131347.GE13406@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0059.outbound.protection.outlook.com ([104.47.37.59]:58528
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758153AbcIHJ6F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 05:58:05 -0400
Content-Disposition: inline
In-Reply-To: <20160824131347.GE13406@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for review the code and valuable comments.

On Wed, Aug 24, 2016 at 03:13:47PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> On Wed, Aug 24, 2016 at 12:27:07PM +0000, Raju Lakkaraju wrote:
> > From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> > PHY Read support will be added for VSC 85xx Microsemi PHYs.
> 
> Why do i need this, when we have SIOCGMIIREG?
> 
Microsemi PHY have different pages i.e. Std IEEE, Extended, Extended_2, Extended_3 and
GPIO pages.
When I want to use SIOCGMIIREG, I can read Std IEEE only with SIOCGMIIREG and not other 
pages.
phy_read_reg function is debug function where I can read entair PHY registers.
In this function, I set the page number and register address then read register value
as atomic operation.

Do you have any suggestions to implement this function in different ways?

Thanks,
Raju.
