From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [PATCH net-next 2/5] ethtool: Implements
 ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE
Date: Fri, 4 Nov 2016 14:31:01 +0100
Message-ID: <20161104133101.GB11277@microsemi.com>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
 <1478255742-25693-3-git-send-email-allan.nielsen@microsemi.com>
 <20161104121332.GJ13959@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <cphealy@gmail.com>,
        <robh@kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0054.outbound.protection.outlook.com ([104.47.40.54]:12832
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754116AbcKDNbb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 09:31:31 -0400
Content-Disposition: inline
In-Reply-To: <20161104121332.GJ13959@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/16 13:13, Andrew Lunn wrote:
> On Fri, Nov 04, 2016 at 11:35:39AM +0100, Allan W. Nielsen wrote:
> > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> > Adding get_tunable/set_tunable function pointer to the phy_driver
> > structure, and uses these function pointers to implement the
> > ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE ioctls.
> For consistency, it would also be nice to add code in
> __ethtool_get_strings().
Okay, we add add that, and I assume you also want ethtool to use it when the
"-k|--show-features" options is invoked?

Are there other cases where this should be used?

/Allan
