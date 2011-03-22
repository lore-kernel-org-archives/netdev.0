From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 3/4] drivers/net/fec: Fix dual MAC support on i.MX28
Date: Tue, 22 Mar 2011 17:22:56 +0800
Message-ID: <20110322092256.GG28098@S2100-06.ap.freescale.net>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
 <e8566dc34c4fd544ac630cf7908e4fb613e3ec1a.1300724245.git.LW@KARO-electronics.de>
 <20110322072832.GD28098@S2100-06.ap.freescale.net>
 <19848.22512.18596.3017@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <u.kleine-koenig@pengutronix.de>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:7764 "EHLO
	VA3EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284Ab1CVJWU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 05:22:20 -0400
Content-Disposition: inline
In-Reply-To: <19848.22512.18596.3017@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2011 at 09:04:00AM +0100, Lothar Wa=DFmann wrote:
> Hi,
>=20
> Shawn Guo writes:
> > Hi Lothar,
> >=20
> > On Mon, Mar 21, 2011 at 05:37:35PM +0100, Lothar Wa=DFmann wrote:
> > > The variant of the FEC chip found on i.MX28 features two distinct
> > > ethernet MACs that both share a single MII interface. When
> > > deconfiguring the eth0 interface, the MII interface is currently =
being
> > > switched off, so that the second MAC won't work any more.
> > >=20
> > I'm wondering what the use case is you intend to support with this
> > patch.
> >=20
> The patch enables the use of both MACs independently from each other.
> Without this patch deconfiguring eth0 would leave eth1 in an unusable
> state.
>=20
Ah, I see.  Just tested it.  It really helps.  Thanks for the patch.

With the patch cleaned up, please add:

Acked-by: <shawn.guo@freescale.com>
Tested-by: <shawn.guo@freescale.com>

--=20
Regards,
Shawn

