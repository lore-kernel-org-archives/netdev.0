From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH net-next 5/6] bnxt_en: Pass RoCE app priority to
 firmware.
Date: Wed, 11 Jan 2017 13:34:08 -0500
Message-ID: <1484159648.2149.42.camel@redhat.com>
References: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
         <1484097159-21575-6-git-send-email-michael.chan@broadcom.com>
         <20170111.104624.1616254027007040020.davem@davemloft.net>
         <CACKFLi=6Nt0hr59zA1BpFNH+_q_kU3eR+F6WFOBwFJ03-RzaEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-jVoLTCiCTZBOPmmR3uvE"
Cc: Netdev <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>,
        David Miller <davem@davemloft.net>,
        Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57342 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751207AbdAKSeK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 13:34:10 -0500
In-Reply-To: <CACKFLi=6Nt0hr59zA1BpFNH+_q_kU3eR+F6WFOBwFJ03-RzaEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jVoLTCiCTZBOPmmR3uvE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-01-11 at 09:17 -0800, Michael Chan wrote:
> On Wed, Jan 11, 2017 at 7:46 AM, David Miller <davem@davemloft.net>
> wrote:
> >=20
> > From: Michael Chan <michael.chan@broadcom.com>
> > Date: Tue, 10 Jan 2017 20:12:38 -0500
> >=20
> > >=20
> > > diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
> > > b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
> > > index 35a0d28..f2630cc 100644
> > > --- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
> > > +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
> > > @@ -36,6 +36,9 @@ struct bnxt_cos2bw_cfg {
> > >=20
> > > =C2=A0#define HWRM_STRUCT_DATA_SUBTYPE_HOST_OPERATIONAL=C2=A0=C2=A0=
=C2=A0=C2=A00x0300
> > >=20
> > > +#define ETH_P_ROCE=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A00x8915
> >=20
> > There's also a similar define in the qedr infiniband driver, this
> > doesn't
> > make much sense.
> >=20
> > Please add this to if_ether.h, and reference it from there in the
> > drivers.
> >=20
> My colleague informed me that he has submitted a patch to do that
> through the rdma tree:
>=20
> http://marc.info/?l=3Dlinux-rdma&m=3D148217575500983&w=3D2
>=20
> But it hasn't been merged yet.=C2=A0=C2=A0I can drop this patch now and w=
ait
> for
> the RDMA patch to show up on net-next. Or I make the change later to
> use the common define when the RDMA patch is merged.=C2=A0=C2=A0Thanks.

The patch for this is in my for-next area:

69ae543969ab RDMA: Adding ethertype ETH_P_IBOE

--=20
Doug Ledford <dledford@redhat.com>
=C2=A0 =C2=A0 GPG KeyID: B826A3330E572FDD
=C2=A0 =C2=A0
Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =C2=A01274 B826 A333 0E57 2FDD

--=-jVoLTCiCTZBOPmmR3uvE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYdnqgAAoJELgmozMOVy/dkysP/14NCf7nnDUJy1nvlAt812qk
bq+pYfbPP0zLkf39FOppiAWWu4HHams5SKegc/bcl/AkbPhJjAxmpKN83ahZ6AUZ
opaiHoVKZrHJtr0pvhgJ6P5JGZA55V5vnhAwwOY69ZZ5xoUPHfAC2wvbn/Cdec87
27a008dHbCv2nr7XCxqAEmhB6WrkQoc2IxSKwbwBpIyDIjSjYhwVX4yopGsi4RJe
Rb2mFwaLRw/Es7STlUQi/1+KnpJhxvx5ky9lMiZh2crNZ5CCDq8gOusaAiZqFEJz
nRsfuAvGaMs/JhA0y3X2xwEiwDCHvgIs72ZeiByo4SlwqdUs0dwv88uUctv0pxzv
SffqqGMEgy4GuYrcpoC/voyNRDF2Rwdb2L9MnxntuNRamRonZNsU4Si+Synv4MtW
q4HTkuRbWOqkKpT7VAN5f7W/oahcEf9jylvxq7AUdaSIJ1xFfl4O4YwdEQriV8aV
Z2cono9Pfzub76eXk7DHLd2J7ICKsvpsqjC8+qONs9ioF90MIrWNRm25rZlRjcp5
xutwLWWaj9lqJE6mBY2OL7en296/pRw/8UMluNpilpJRWp6Gj5cgJRYHkOCoR2pP
DuLKjngnjnwR2fLKQzlKsI+MTYLT91Hp337Rem2WYqTxzJhRiv+gMm2q/Fd4HndY
H2ISc98lvJG9RBL0LQXm
=clBU
-----END PGP SIGNATURE-----

--=-jVoLTCiCTZBOPmmR3uvE--
