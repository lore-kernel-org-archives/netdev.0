From: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Wed, 30 Nov 2016 14:30:43 +0000
Message-ID: <1480516241.3563.142.camel@infinera.com>
References: <1480495831.3563.135.camel@infinera.com>
         <20161130135257.GC18716@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0084.outbound.protection.outlook.com ([104.47.38.84]:44112
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757135AbcK3OqE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 09:46:04 -0500
In-Reply-To: <20161130135257.GC18716@lunn.ch>
Content-Language: en-US
Content-ID: <34A6522AB6001B478278B6C4A7FECA21@infinera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 14:52 +0100, Andrew Lunn wrote:
> On Wed, Nov 30, 2016 at 08:50:34AM +0000, Joakim Tjernlund wrote:
> > I am trying to wrap my head around these two "devices" and have a hard =
time telling them apart.
> > We are looking att adding a faily large switch(over PCIe) to our board =
and from what I can tell
> > switchdev is the new way to do it but DSA is still there. Is it possibl=
e to just list
> > how they differ?
>=20
> Hi Joakim

Hi Andrew, thanks for answering

>=20
> If the interface you use to send frames from the host to the switch is
> PCIe, you probably want to use switchdev directly.

OK, we will have a few ethernet I/F's connected too but I these should be u=
sed
as normal interfaces just interfacing a switch.

>=20
> DSA devices all use a host Ethernet interface to send frames to the
> switch. DSA sits under switchdev, and effectively provides a lot of
> the common stuff needed for implementing switch drivers of this
> sort. It creates the slave interfaces, links the MAC to the PHY, has
> one uniform device tree binding which all DSA switches have, deals
> with encapsulation/decapsulating frames sent over the master device,
> etc.

And switchdev can do all this over PCIe instead? Can you have a switch tree=
 in switchdev too?

We probably need to push a custom tag for final step (after the switch) and=
 I think that
should be doable with a custom VLAN driver over one/several of switchdev's =
virtual
interfaces?=20

 Joakim=
