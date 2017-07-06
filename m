From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Thu, 6 Jul 2017 23:39:41 +0000
Message-ID: <MWHPR12MB16009D656DD4408DE4429274C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
 <20170627032239.05cdc462@cakuba.netronome.com>
 <20170628134139.GB12559@lunn.ch>
 <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
 <20170628180008.42059797@cakuba.netronome.com>
 <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706120214.6076be46@cakuba.netronome.com>
 <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706223324.GA24237@lunn.ch>
 <MWHPR12MB1600B8ECA4222A062CDC71C0C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>,<20170706231550.GC24237@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
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
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0115.outbound.protection.outlook.com ([104.47.42.115]:22528
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752871AbdGFXjp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 19:39:45 -0400
In-Reply-To: <20170706231550.GC24237@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Andrew Lunn <andrew@lunn.ch>
| Sent: Thursday, July 6, 2017 4:15 PM
| =A0  =20
| > Even this feels too extreme for me.=A0 I think users would hate it.=A0 =
They
| > did an ifup and swapped cables.=A0 They expect the OS/Driver/Firmware
| > to continue trying to honor their ifup request.
|=20
| Lets take a look around at other subsystems....
| ...
| Do you know of any subsystem that tried to keep its configuration
| across a hot unplug/plug event? I suspect they all require user space
| to take some action to get the newly plugged hardware into operation.

I agree ... -ish ... :-)

If you choose to think of a cable unplug/plug event as "hot plug", then
the "reset" is the model that feels right.  But I'll note that this is also
presupposing what the right model is for users.  This is akin
to trying to decide what to make for dinner and deciding that a
hammer is the right tool.  If we end up deciding on Cracked
Crab (or Tree Nuts for the vegans amongst us), then the
hammer is quite possibly a good answer.

All I can continue to say is: keep on thinking about users.  How they're
using networking devices now, how they think about them, how we're
going to explain to them whatever changes they'll need to make to
their usage of network ports.  And yes, how this will fit into management
models for other OSes, etc.

The customers aren't always right, but their opinion matters a lot.

Casey=
