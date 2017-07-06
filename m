From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH net-next 1/3] net: ethtool: add support for forward
 error correction modes
Date: Thu, 6 Jul 2017 22:16:08 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6265049232F@ORSMSX102.amr.corp.intel.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
        <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
        <20170627032239.05cdc462@cakuba.netronome.com>
        <20170628134139.GB12559@lunn.ch>
        <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
        <20170628180008.42059797@cakuba.netronome.com>
        <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>,<20170706120214.6076be46@cakuba.netronome.com>
 <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dustin Byford <dustin@cumulusnetworks.com>,
        Andrew Lunn <andrew@lunn.ch>,
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
To: Casey Leedom <leedom@chelsio.com>, Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:38772 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751943AbdGFWQN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 18:16:13 -0400
In-Reply-To: <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Casey Leedom
> Sent: Thursday, July 06, 2017 2:54 PM
> To: Jakub Kicinski <kubakici@wp.pl>
> Cc: Dustin Byford <dustin@cumulusnetworks.com>; Andrew Lunn
> <andrew@lunn.ch>; Roopa Prabhu <roopa@cumulusnetworks.com>;
> davem@davemloft.net; linville@tuxdriver.com; netdev@vger.kernel.org;
> vidya.chowdary@gmail.com; olson@cumulusnetworks.com; Manoj Malviya
> <manojmalviya@chelsio.com>; Santosh Rastapur <santosh@chelsio.com>;
> yuval.mintz@qlogic.com; odedw@mellanox.com; ariela@mellanox.com;
> galp@mellanox.com; Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
> correction modes
> 
> | From: Jakub Kicinski <kubakici@wp.pl>
> | Sent: Thursday, July 6, 2017 12:02 PM
> |
> | IMHO if something gets replugged all the settings should be reset.
> | I feel that it's not entirely unlike replugging a USB adapter.  Perhaps
> | we should introduce some (devlink) notifications for SFP module events
> | so userspace can apply whatever static user config it has?
> 
> Absolutely a valid approach.  As are all of the ones I outlined.
> 
[..]
> As I noted in my previous letter: this is something new that we've never
> faced before with any prior networking technology.  All previous networking
> technologies had a static set of Physical Port Capabilities fixed from the
> moment a Host Diver/Firmware first see a Port.  We're now facing a situation
> where these can change dynamically from moment to moment based on what
> Transceiver Module is inserted.

Agree with your points generally, but other networking hw vendors have dealt with this since SFP variant and other modules arrived on the scene.  
