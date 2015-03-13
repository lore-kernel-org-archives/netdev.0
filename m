From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] ixgbe: Remove NETIF_F_HW_VLAN_CTAG_FILTER from
 hw_features
Date: Fri, 13 Mar 2015 04:58:28 -0700
Message-ID: <1426247908.2670.6.camel@jtkirshe-mobl>
References: <20150312152055.1319.61781.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6fAFJ0ESO7sb4/xYiqOp"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	h-shimamoto@ct.jp.nec.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54101 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752756AbbCML63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 07:58:29 -0400
In-Reply-To: <20150312152055.1319.61781.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6fAFJ0ESO7sb4/xYiqOp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-03-12 at 08:22 -0700, Alexander Duyck wrote:
> This change makes it so that the HW_VLAN_CTAG_FILTER bit is not
> falsely
> advertised as being a feature that can be toggled on ixgbe parts.  The
> driver was setting the bit in features and letting it be inherited by
> hw_features, however the driver was actually ignoring the value of the
> bit
> and just assuming it was always set.  As a result VLAN filtering was
> always
> enabled which is a requirement for SR-IOV, VMDq, DCB, FCoE, and
> possibly
> other features within the adapters.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>=20
> v2: Updated patch description replacing STAG reference with CTAG
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Alex, I have applied your updated patch to my queue.

git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-6fAFJ0ESO7sb4/xYiqOp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVAtDkAAoJEOVv75VaS+3OJ/IQAI2x8K1pbUCByN1gVRfr6Vk9
Hfnttq2oUfQ9IlG20ID6DKqhZ9EMy++cz3Obc/2qbq6O5nDT1iaix++d4q10Nk7P
EcyUNuDyS5AV+xgV38GTEW3KiLtBmdU9HLSYw3j2KTD31mTte9bRCxmoj23l4SEC
sqW2TPzG9nxpWpFLNl/dNPAX/HjbFDFu5mgEy2Q/KCpojf1JP0sK+IzdJ7QaP0LU
opan8BzB5z0XF1TJ+ga1eleds0V3h872EtOaTTQBcRF+VcfCy0Jhp9zDEb+6eAQp
V6p5pQv2cd5P2XQN8hBVxxAJJqzq/hT195Lmoyl89FzgJTEkT4qp25LaGFjT8JNx
Lfvl8TYtws4FwYfLExoqacm2v6qqXz/ZbBSyMTdtTE6z9ER8iJbQAfyxuaJy7/E4
1lrPWvp7+TU7b55Otk27YNMIqA/e6myYvm+p0BwlL03mcNr9dqPPjTug2QvVpL99
v45Z7zjH3UFO1Gb1DiIwyFj/E6jH/1IE8CgOGoKvrYxm6sgASEdnBars57xpY/pr
GARaubcsDpMua5ggxzguEnabIjWiUeR02dYfZLtkLp5H6bSZV1EXdrJSt3GQHR0x
O8Jlv99t1nbO+AlnZJluOQyNRawoYWRl5otIUD/Fb3D1aLRrFgGI//cXavQzKqUQ
pghFbzVKowgARhKXrEy1
=npLB
-----END PGP SIGNATURE-----

--=-6fAFJ0ESO7sb4/xYiqOp--
