From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCHv2 net 2/2] fm10k: Implement ndo_gso_check()
Date: Thu, 13 Nov 2014 16:12:39 -0800
Message-ID: <1415923959.2454.44.camel@jtkirshe-mobl>
References: <1415921801-10452-1-git-send-email-joestringer@nicira.com>
	 <1415921801-10452-2-git-send-email-joestringer@nicira.com>
	 <1415922116.2454.34.camel@jtkirshe-mobl> <20141113235219.GA35957@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WW/k0d8CzdPP1tEpE+zI"
Cc: Shannon Nelson <shannon.nelson@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, matthew.vick@intel.com,
	linux.nics@intel.com, therbert@google.com, gerlitz.or@gmail.com,
	alexander.duyck@gmail.com, linux-kernel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141113235219.GA35957@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WW/k0d8CzdPP1tEpE+zI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-13 at 15:52 -0800, Joe Stringer wrote:
> On Thu, Nov 13, 2014 at 03:41:56PM -0800, Jeff Kirsher wrote:
> > On Thu, 2014-11-13 at 15:36 -0800, Joe Stringer wrote:
> > > ndo_gso_check() was recently introduced to allow NICs to report
> the
> > > offloading support that they have on a per-skb basis. Add an
> > > implementation for this driver which checks for something that
> looks
> > > like VXLAN.
> > >=20
> > > Signed-off-by: Joe Stringer <joestringer@nicira.com>
> > > ---
> > > v2: Reuse fm10k_tx_encap_offload().
> > > ---
> > >  drivers/net/ethernet/intel/fm10k/fm10k.h        |    1 +
> > >  drivers/net/ethernet/intel/fm10k/fm10k_main.c   |    2 +-
> > >  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |    8 ++++++++
> > >  3 files changed, 10 insertions(+), 1 deletion(-)
> >=20
> > Same with this one as well, thanks Joe.
>=20
> Thanks Jeff.
>=20
> Could you remind me, is the equivalent i40e patch on your queue or
> were
> we still waiting on further feedback from Shannon/Jesse?

Actually, looks like I dropped the patch due to community feedback and
was expecting a v2.  Was I incorrect in doing so?

--=-WW/k0d8CzdPP1tEpE+zI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUZUj3AAoJEOVv75VaS+3ORHgP/0Unb9RBX7bIJWuGJPV9eKNp
6DNoBxL6SQh8PkI39uXDIAKK9tTrJLZLAecw+8Xy/sq6ssFvLV6gZNVMMR7o0XsT
JHezHXe/NhOiFr/vksqog4f04/3rNChYPVkuW/tz7VD/rN6+rNC3hkoDZ4EkBsn+
2O0mDS6T4d9Qgb4jeAEYsC2qQU0Q3vGhOaBrFrzJRkiPfLEpIfvZAjeusXaGdedS
rzBa6X1SF0WFl9fdJjFDLkOw94uBKtlQpPptehrPSF/GxO/O3NFCxVvoRxj3fo4y
05al/j2tm6MSmgvgTTE6xOo+e3MVPGF8e7vMl5QqyidtkwEbwiNLlzIYAtgL49vP
qJ6+ceN7QVofaLO6rSRyYKl99pD0Vwv2j4n9i1v3HANNZpUuuEa/gSnM0qBpeaMZ
oy/c6j03OlOTHqSbwFnk0FoQgmYQH1PDAAXVI0uR7JKvTXptC+qf5C/28TBOF4uE
5V+L55V9Gg/G2jXZCtsJQ+Y1hdN2nTXTr8I21ON9A4FGi17vBR+wUfxUSXoIRz2M
4QPaf8xsMczenr6DNTOK0gu36+7QsBqOEjA4lRMG2DX3UczQzFez+CkvkIvOw6es
PpZ1UlWRj5j6PsZSFSMWH6FDqhxTXBdTUctXjfhFaU3qPaWOiWwNCIvPrCtpSiyB
Ur6iWyRCzdY4LiCEGwDk
=yT5g
-----END PGP SIGNATURE-----

--=-WW/k0d8CzdPP1tEpE+zI--
