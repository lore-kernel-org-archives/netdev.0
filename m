From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH net-next 1/2] net: phy: Add Speed downshift set driver
 for Microsemi PHYs.
Date: Mon, 17 Oct 2016 13:01:54 +0530
Message-ID: <20161017073152.GA2365@microsemi.com>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1476445233-26524-2-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20161014121232.GH5822@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0059.outbound.protection.outlook.com ([104.47.41.59]:35712
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757465AbcJQHce (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 03:32:34 -0400
Content-Disposition: inline
In-Reply-To: <20161014121232.GH5822@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for code review and comments.

On Fri, Oct 14, 2016 at 02:12:32PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> On Fri, Oct 14, 2016 at 05:10:32PM +0530, Raju Lakkaraju wrote:
> > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> > For operation in cabling environments that are incompatible with
> > 1000BAST-T, VSC8531 device provides an automatic link speed
> > downshift operation. When enabled, the device automatically changes
> > its 1000BAST-T auto-negotiation to the next slower speed after
> > a configured number of failed attempts at 1000BAST-T.
> > This feature is useful in setting up in networks using older cable
> > installations that include only pairs A and B, and not pairs C and D.
> 
> Any reason not to just turn this on by default when auto-neg is
> enabled?
> 
Downshift can enable by default when auto-neg enabled. This is good idea.
But we would like to provide option to customer can choose whether this
feature need to enable or disable and also configure failure attempts.

Do you have any other suggestion how to configure failure attempts?

>         Andrew

---

Thanks,
Raju.
