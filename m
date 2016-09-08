From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/4] net: phy: Add read driver for Microsemi PHYs.
Date: Thu, 8 Sep 2016 15:40:26 +0200
Message-ID: <20160908134026.GI26445@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A1453366A5@avsrvexchmbx1.microsemi.net>
 <20160824131347.GE13406@lunn.ch>
 <20160908094211.GA4281@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38886 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757562AbcIHNk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 09:40:28 -0400
Content-Disposition: inline
In-Reply-To: <20160908094211.GA4281@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Microsemi PHY have different pages i.e. Std IEEE, Extended,
> Extended_2, Extended_3 and GPIO pages.

Yes, nothing special there. Marvell does the same, and probably
others.

> When I want to use SIOCGMIIREG, I can read Std IEEE only with
> SIOCGMIIREG and not other pages.

So this is purely for your own debug. So you can hack in anything you
want. Just don't submit it for mainline.

Or you can do it properly. Take a look at the sources for
mii-tool. Figure out a way to do it cleanly which will work for all
phys which support multiple pages. Then submit patches which does this
for both your own PHY and one other manufacture. I can help with
Marvell PHYS, if that is what you want.

What will never get accepted is something which is not generic. What
you submit must work for multiple vendors, and you need to submit it
all, from the userspace/kernel space API all the way down to the PHY,
and ideally patches to mii-tool as well.

    Andrew
