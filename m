From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: phy: Add config option to specify external switch port to be used if switch is used as PHY
Date: Thu, 8 Sep 2011 23:24:30 +0200
Message-ID: <20110908212430.GA27980@electric-eye.fr.zoreil.com>
References: <4E68668F.9060008@televic.com> <20110908101315.GA27909@electric-eye.fr.zoreil.com> <4E68AE26.5020707@televic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>
To: Lambrecht =?utf-8?Q?J=C3=BCrgen?= <J.Lambrecht@TELEVIC.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36365 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355Ab1IHXRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 19:17:31 -0400
Content-Disposition: inline
In-Reply-To: <4E68AE26.5020707@televic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lambrecht J=C3=BCrgen <J.Lambrecht@TELEVIC.com> :
> On 09/08/2011 12:13 PM, Francois Romieu wrote:
[...]
> > Which driver(s) do you use that you can not set phy_mask directly ?
> >
> The HW driver is 'FEC' for iMX Ethernet. For the PHY, just MII and PH=
YLIB.
> I am rather new to linux, didn't knew phy_mask. Checked it now, and i=
s=20
> not set in fec.c.
> You mean then to patch drivers/net/fec.c in the same way (as my curre=
nt=20
> patch) to set the phy_mask instead (via menuconfig, or in the platfor=
m=20
> init)?

It is not my area but I would have drivers/net/fec.c::fec_devtype.drive=
r_data
point to a real struct where the relevant phy_mask and the current quir=
ks
are stored, then add a new entry in fec_devtype and a reference to it
(Kconfig + platform init) somewhere below arch/arm/plat-mxc.

=46reescale's application note suggests that the MX25 fec allows some f=
reedom
for the implementation of the media interface. So it may not be overkil=
l.

--=20
Ueimor
