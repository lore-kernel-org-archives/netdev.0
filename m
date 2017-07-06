From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Fri, 7 Jul 2017 01:15:50 +0200
Message-ID: <20170706231550.GC24237@lunn.ch>
References: <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
 <20170627032239.05cdc462@cakuba.netronome.com>
 <20170628134139.GB12559@lunn.ch>
 <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
 <20170628180008.42059797@cakuba.netronome.com>
 <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706120214.6076be46@cakuba.netronome.com>
 <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706223324.GA24237@lunn.ch>
 <MWHPR12MB1600B8ECA4222A062CDC71C0C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <kubakici@wp.pl>,
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
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47330 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752733AbdGFXP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 19:15:58 -0400
Content-Disposition: inline
In-Reply-To: <MWHPR12MB1600B8ECA4222A062CDC71C0C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Even this feels too extreme for me.  I think users would hate it.  They
> did an ifup and swapped cables.  They expect the OS/Driver/Firmware
> to continue trying to honor their ifup request.

Lets take a look around at other subsystems....

What happens if you hot-unplug a SATA drive?
An MMC card?
A USB device?
A PCIe card?
A CPU?
An SDRAM?

Do you know of any subsystem that tried to keep its configuration
across a hot unplug/plug event? I suspect they all require user space
to take some action to get the newly plugged hardware into operation.

       Andrew
