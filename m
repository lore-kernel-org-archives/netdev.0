From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 1/17 v2] can: EG20T PCH: Separate
 Interface Register(IF1/IF2)
Date: Wed, 24 Nov 2010 11:54:25 +0100
Message-ID: <1290596065.3464.30.camel@edumazet-laptop>
References: <4CECBFE3.8030402@dsn.okisemi.com>
	 <4CECEC85.1050009@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	andrew.chih.howe.khor@intel.com, qi.wang@intel.com,
	margie.foster@intel.com, yong.y.wang@intel.com,
	kok.howg.ewe@intel.com, joel.clark@intel.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54636 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab0KXKyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 05:54:37 -0500
In-Reply-To: <4CECEC85.1050009@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 novembre 2010 =C3=A0 11:44 +0100, Marc Kleine-Budde a =C3=
=A9crit :
> On 11/24/2010 08:33 AM, Tomoya MORINAGA wrote:
> > Separate interface register from whole of register structure.
> > CAN register of Intel PCH EG20T has 2 sets of interface register.
> > To reduce whole of code size, separate interface register.
> > As a result, the number of function also can be reduced.
>=20
> I failed to apply your series to david's net-2.6/master. Please resub=
mit.
>=20
> > Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
> > ---
> >  drivers/net/can/pch_can.c |  442 ++++++++++++++++++++-------------=
------------
> >  1 files changed, 198 insertions(+), 244 deletions(-)
> >=20
> > diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> > index 238622a..143f100 100644
> > --- a/drivers/net/can/pch_can.c
> > +++ b/drivers/net/can/pch_can.c
> > @@ -102,6 +102,9 @@
> >  #define PCH_MSK_CTRL_IE_SIE_EIE	0x07
> >  #define PCH_COUNTER_LIMIT	10
> > =20
> > +#define PCH_RX_IFREG			0
> > +#define PCH_TX_IFREG			1
>=20
> Please make this enum _here_, not in a later patch.
>=20

[then, huge part deleted, containing no review, spent some time to
discover this...]

Marc, could you please dont include the whole mail in your replies ?

We have a high Noise Rate on this topic already.

Thanks


