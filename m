From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: take online CPU number as MQ max limit when
 alloc_etherdev_mq()
Date: Mon, 16 May 2016 13:58:42 -0700
Message-ID: <1463432322.2609.12.camel@intel.com>
References: <1463118995-31763-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-UkNUNi+QmcfXAo94WkoH"
Cc: linux-kernel@vger.kernel.org, ethan.kernel@gmail.com
To: Ethan Zhao <ethan.zhao@oracle.com>, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463118995-31763-1-git-send-email-ethan.zhao@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-UkNUNi+QmcfXAo94WkoH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-05-13 at 14:56 +0900, Ethan Zhao wrote:
> Allocating 64 Tx/Rx as default doesn't benefit perfomrnace when less
> CPUs were assigned. especially when DCB is enabled, so we should take
> num_online_cpus() as top limit, and aslo to make sure every TC has
> at least one queue, take the MAX_TRAFFIC_CLASS as bottom limit of queues
> number.
>=20
> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++++
> =C2=A01 file changed, 4 insertions(+)

Dropping this patch based on Alex's and John's feedback.
--=-UkNUNi+QmcfXAo94WkoH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXOjSCAAoJEOVv75VaS+3OgwAP/iswNKomnUJXx5wixfTtMVyv
XxzBsrhubT1OmrsEKBWI8r3Gd1UCQJufd00PeJTVCTszjzQzUHYSRIkRlpOlbuny
BKVIt6TOhrsllvPGXK7Sut8vrLYWnQVQ6WCKeczW6IOFA1TFxFsMjpPg3/KUi2jN
025zvsavMaIZ8ptaL6QjDevGBJkkTxyhEKzB4luZm5NDf3YZWP2Ulml04k4y6rYZ
WatTqpeY8mGNlmbPa0bW28n2B1flAyT3FenLsnbMq3UwttE9L3OiUtjgpXe/XpCx
byMBb0egozS3twryRtPTxpG7/CiE0Yh7fJ6FVXIl98CAAczKUNQnvmz8vHeZ7i0r
Wje/i4Jxh+HRSOFGG2laTqWhXWNuM8NWGzXXWmRzTAdet5WGbx5PazBg6lmmUn1m
Uk/juElZkf7k+ypQfyq+6cB5Hf71FF3GIAS7OHJsBhNcnt3p2UWuxhtDPGpaZ0gY
nIoBkNRUgrFitkvptLBh4lIRtwduRbWwImZAQ6gQ1ByR+8ASkwdbOwseIkgWhE/r
/AR3LqKYzvqECGpjaWe+iPjC5bSai52yWb0WVxaqJzQtII7F9fqAMBdq6nhP1lhs
IbdlcqTzRlRoMUpWWifmvjG9orXq3zRVnwTePiEWjc1BiLC7B268Q8BuOcybrC82
+hpfjgDLgFiyGallzTll
=jrEd
-----END PGP SIGNATURE-----

--=-UkNUNi+QmcfXAo94WkoH--
