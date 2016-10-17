From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH V3 RFC 2/2] ixgbe: ixgbe_atr() compute
 l4_proto only if non-paged data has network/transport headers
Date: Mon, 17 Oct 2016 15:37:51 -0700
Message-ID: <1476743871.2326.52.camel@intel.com>
References: <cover.1476737917.git.sowmini.varadhan@oracle.com>
         <07bf787b2a346e12ca6e57edaf1a3025de9ae5dc.1476737917.git.sowmini.varadhan@oracle.com>
         <CAKgT0Ue7HL4CWdF2jBzLYOqXuO2=J9GeF79qfcdOWB7+cA0_3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-i3FiAMCFm4K5HJPKL+j3"
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43306 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932817AbcJQWhy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 18:37:54 -0400
In-Reply-To: <CAKgT0Ue7HL4CWdF2jBzLYOqXuO2=J9GeF79qfcdOWB7+cA0_3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-i3FiAMCFm4K5HJPKL+j3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-10-17 at 15:29 -0700, Alexander Duyck wrote:
> On Mon, Oct 17, 2016 at 2:12 PM, Sowmini Varadhan
> <sowmini.varadhan@oracle.com> wrote:
> >=20
> > For some Tx paths (e.g., tpacket_snd()), ixgbe_atr may be
> > passed down an sk_buff that has the network and transport
> > header in the paged data, so it needs to make sure these
> > headers are available in the headlen bytes to calculate the
> > l4_proto.
> >=20
> > This patch expect that network and transport headers are
> > already available in the non-paged header dat.=C2=A0=C2=A0The assumptio=
n
> > is that the caller has set this up if l4_proto based Tx
> > steering is desired.
> >=20
> > Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>=20
> This all looks correct to me.=C2=A0=C2=A0I would recommend having Jeff pu=
ll it
> in to be submitted to the net queue.
>=20
> Reviewed-by: Alexander Duyck <alexander.h.duyck@intel.com>

Sowmini, can you re-submit this to intel-wired-lan but without the RFC in
the title?
--=-i3FiAMCFm4K5HJPKL+j3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYBVK/AAoJEOVv75VaS+3ODJkP/Ro8O4LpIXmpWICi36OAwoXa
nN+xniIfHo0q8LfLeJU4wXilsxcU/GmvcNyfAuIyUiaGqcEog/BE8EPyNqcdbJfH
mMn5/s7e93KthXGmu8JgBx97jna9OvpBf4pDjksGHUAkGCFLmBiY7D/f3/HPmKwY
nl3lEFGqzSYia99TIsTNj8qzKU++Uou1RJwk89yAlU3SWrUWFXPSksUvB69DGKWt
jr+Txz4Era3OwRmeCL/p5DyIV1cgHUvHGtuk7ClPnBgkZuhCi+OX1k1nSHG3hcOU
2VNL5SUKRKr2EGrS4TN8sMv8si14uRhmue2qZ9MzEyV1RL6pngw8Cy7bPb9qVpkq
aI67Wj8zOhmV/frEZ4sIEDAtWbO51bRGz92XdlAUR3os1vQBSj8bNwZuA08JXdSL
W8wSO5+FS3O/7o2fs42f8iv5rGcyqPKok+oa+abQ823IGHIVwCx8PAJ7XV2pQV0Z
bKdiRHbcFQiiQ5wmAuQo6rPZixQXnLKovM/l74hEP+xmA+yquQofAX/NiPoNuUEh
lHzGQ57M911kyZbJ30yddi4i3zjs3d7kQIRorhiwTx+4SCiDJ7i0BecGGES9oIVS
B51fhYeaKJB5agazs/rkKXGosc5Ul59xD9RYHwobco1Q6zXqOIaWPH1XmtFVK8j6
o/rD/wdLZ/cTm4dPtTnl
=83jf
-----END PGP SIGNATURE-----

--=-i3FiAMCFm4K5HJPKL+j3--
