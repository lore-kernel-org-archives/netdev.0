From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 01/11] qede: Fix sparse warnings
Date: Mon, 22 May 2017 16:48:25 +0000
Message-ID: <BLUPR0701MB2004062F133B0DD22E817C6C8DF80@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
        <1495452731-27171-2-git-send-email-Yuval.Mintz@cavium.com>
 <20170522.123804.1189830414503494485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Chopra, Manish" <Manish.Chopra@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0066.outbound.protection.outlook.com ([104.47.42.66]:2224
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934376AbdEVQs2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 12:48:28 -0400
In-Reply-To: <20170522.123804.1189830414503494485.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, May 22, 2017 7:38 PM
> To: Mintz, Yuval <Yuval.Mintz@cavium.com>
> Cc: netdev@vger.kernel.org; Chopra, Manish <Manish.Chopra@cavium.com>
> Subject: Re: [PATCH net-next 01/11] qede: Fix sparse warnings
>=20
> From: Yuval Mintz <Yuval.Mintz@cavium.com>
> Date: Mon, 22 May 2017 14:32:01 +0300
>=20
> > From: Manish Chopra <Manish.Chopra@cavium.com>
> >
> > Signed-off-by: Manish Chopra <Manish.Chopra@cavium.com>
> > Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> > ---
> >  drivers/net/ethernet/qlogic/qede/qede_dcbnl.c   |  1 -
> >  drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 10 ++++++----
> >  drivers/net/ethernet/qlogic/qede/qede_fp.c      | 25 ++++++++++++++---=
----
> ----
> >  drivers/net/ethernet/qlogic/qede/qede_roce.c    |  4 ++--
> >  4 files changed, 22 insertions(+), 18 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
> > b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
> > index a9e7379..6e7747b 100644
> > --- a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
> > +++ b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
> > @@ -313,7 +313,6 @@ static int qede_dcbnl_ieee_peer_getets(struct
> net_device *netdev,
> >  	.ieee_setets =3D qede_dcbnl_ieee_setets,
> >  	.ieee_getapp =3D qede_dcbnl_ieee_getapp,
> >  	.ieee_setapp =3D qede_dcbnl_ieee_setapp,
> > -	.getdcbx =3D qede_dcbnl_getdcbx,
> >  	.ieee_peer_getpfc =3D qede_dcbnl_ieee_peer_getpfc,
> >  	.ieee_peer_getets =3D qede_dcbnl_ieee_peer_getets,
> >  	.getstate =3D qede_dcbnl_getstate,
>=20
> Please.
>=20
> This is exactly the problem when such a terse commit message, or lack of =
any
> message at all as is the case here, occurs.
>=20
> I have no idea what removing this method assignment has to do with fixing
> sparse warnings.

It's currently defined twice in the qede_dcbnl_ops struct -

  .ieee_setapp =3D qede_dcbnl_ieee_setapp,
  .getdcbx =3D qede_dcbnl_getdcbx,
  .ieee_peer_getpfc =3D qede_dcbnl_ieee_peer_getpfc,=09
  ...
  .getapp =3D qede_dcbnl_getapp,
  .getdcbx =3D qede_dcbnl_getdcbx,
  .setpgtccfgtx =3D qede_dcbnl_setpgtccfgtx,
