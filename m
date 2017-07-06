From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Fri, 7 Jul 2017 00:36:47 +0200
Message-ID: <20170706223647.GB24237@lunn.ch>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
 <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
 <20170627032239.05cdc462@cakuba.netronome.com>
 <20170628134139.GB12559@lunn.ch>
 <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
 <20170628180008.42059797@cakuba.netronome.com>
 <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706120214.6076be46@cakuba.netronome.com>
 <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <9BBC4E0CF881AA4299206E2E1412B6265049232F@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Casey Leedom <leedom@chelsio.com>, Jakub Kicinski <kubakici@wp.pl>,
        Dustin Byford <dustin@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "vidya.chowdary@gmail.com" <vidya.chowdary@gmail.com>,
        "olson@cumulusnetworks.com" <olson@cumulusnetworks.com>,
        Manoj Malviya <manojmalviya@chelsio.com>,
        Santosh Rastapur <santosh@chelsio.com>,
        "yuval.mintz@qlogic.com" <yuval.mintz@qlogic.com>,
        "odedw@mellanox.com" <odedw@mellanox.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47301 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752068AbdGFWg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 18:36:56 -0400
Content-Disposition: inline
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B6265049232F@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Agree with your points generally, but other networking hw vendors
> have dealt with this since SFP variant and other modules arrived on
> the scene.

It seems like there is interest now in consolidating this, in the same
way that copper PHYs got consolidated. Yes, there are some MAC drivers
which still have there own PHY drivers, but most Ethernet MAC drivers
use phylib.

Now maybe the time for an sfplib.

    Andrew
