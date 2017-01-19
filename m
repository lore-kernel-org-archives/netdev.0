From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH for bnxt_re V4 10/21] RDMA/bnxt_re: Support for CQ verbs
Date: Thu, 19 Jan 2017 01:57:33 -0500
Message-ID: <1484809053.2406.90.camel@redhat.com>
References: <CA+sbYW0+Z2X+_BqG=QNBSgc0Qsk1S9sZYieUuN05PjF5or4NkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-0XXfxMoXDiU/DSRQiya2"
Cc: linux-rdma@vger.kernel.org,
        Linux Netdev List <netdev@vger.kernel.org>,
        Michael Chan <michael.chan@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Selvin Xavier <selvin.xavier@broadcom.com>,
        Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40696 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751329AbdASG5g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 01:57:36 -0500
In-Reply-To: <CA+sbYW0+Z2X+_BqG=QNBSgc0Qsk1S9sZYieUuN05PjF5or4NkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0XXfxMoXDiU/DSRQiya2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-01-18 at 14:42 +0530, Selvin Xavier wrote:
> On Wed, Jan 18, 2017 at 1:49 PM, Leon Romanovsky <leon@kernel.org>
> wrote:
> >=20
> > It is better to use already existing macros - min()
> > cq->max_cql =3D min(entries, MAX_CQL_PER_POLL);
> >=20
> > I afraid that you can't avoid the respinning, you have more than
> > month
> > till merge window.
> >=20
> > Can you please remove useless wrappers and try to reuse kernel
> > macros?
>=20
> Leon,
> =C2=A0 Thanks for your comments. I will include your both comments in the
> next patch set.
>=20
> Doug,
> =C2=A0=C2=A0=C2=A0Is it ok if I send out the V5 now after re-basing again=
st for-4.11
> branch or should i wait for your comments on V4?

Wait.

--=20
Doug Ledford <dledford@redhat.com>
=C2=A0 =C2=A0 GPG KeyID: B826A3330E572FDD
=C2=A0 =C2=A0
Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =C2=A01274 B826 A333 0E57 2FDD

--=-0XXfxMoXDiU/DSRQiya2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYgGNdAAoJELgmozMOVy/dLO0QALOnc0i3+N48KdicL7wfRtJL
ikNADemN9GXbauVmd2eyIzOFlbnDLWrWKlrZCW+lK+rbfsAH0vTh4Kjxy9zKn8XZ
nfluUVsvjQJfQmQfxTppnKJYI5NkMBQM80L1+IU0Du6GUan+hPZoVSBjlnzl51Da
MbBnfBTo9cw/dHVZWyYn/z5w3b8HVe8x6ciD3V1pMlAEQeOlklR/y/TYFJ1htJXT
OxjCoh9tAJtnUBMCoY6y89DRJcUFcVKRVy2HdHchLcx/+tRshaAD9aqTrQshU7P+
LHCL2BrUgb//GfxHx2Gsx3Oqyor/q7deVOdsbuST17/u0wXfc2fNF934dsbrQZ3e
0ruBrAJUTDLYg/ycFrtXpsJOxDrkHCvwDS679Ysnh+vKkdpi1K625/njjnE2zQu+
cgEcblqYkhn6w1QDapbEWaePIBNUpaARa7Hej0FILFgX1RFsmr3EjPfZBXR/kh9T
WboF92/eEa2h0RZ8VAI/zwintE1juNgZXDL20NkXy3G26JmXLx3ju5uDN0ZevDp7
377EZu7ask/yKpFOqxtcya6n9MW1lsVMCttEKXy6qdF8C8paFsA6Krp0J/t7TNge
rlnVc/69oIWr89eNNie5rL7kQAPyuPjU/nkrGVS1xRNpwPajrtB9hOgoF2TLAAIj
j7X8SThBnD7PGyM/NkwR
=oNNn
-----END PGP SIGNATURE-----

--=-0XXfxMoXDiU/DSRQiya2--
