From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/1] net/e1000e: Avoid kernel crash during shutdown
Date: Tue, 13 Aug 2013 03:29:01 -0700
Message-ID: <1376389741.27277.0.camel@jtkirshe-mobl>
References: <1376375227-24274-1-git-send-email-zhlcindy@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qQ8bFvbHOMiBf9zOd7O+"
Cc: jesse.brandeburg@intel.com, davem@davemloft.net,
	netdev@vger.kernel.org, shangw@linux.vnet.ibm.com
To: Li Zhang <zhlcindy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16794 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753155Ab3HMK3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 06:29:33 -0400
In-Reply-To: <1376375227-24274-1-git-send-email-zhlcindy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qQ8bFvbHOMiBf9zOd7O+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-08-13 at 14:27 +0800, Li Zhang wrote:
> While doing shutdown on the PCI device, the corresponding callback
> function e1000e_shutdown() is trying to clear those correctable
> errors on the upstream P2P bridge. Unfortunately, we don't have
> the upstream P2P bridge under some cases (e.g. PCI-passthrou for
> KVM on Power). That leads to kernel crash eventually.
>=20
> The patch adds one more check on that to avoid kernel crash.
>=20
> Signed-off-by: Li Zhang <zhlcindy@gmail.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 7 +++++++
>  1 file changed, 7 insertions(+)

Thanks Li, I will add this to my queue of patches.


--=-qQ8bFvbHOMiBf9zOd7O+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSCgptAAoJEOVv75VaS+3OcaUP/3SVCFeNsIMuFrQVsP/+bt20
GZTx2qbjMg3NjLGUjbTbeI9erik6+teVumz+jP7LenSek0zovdl4p9PV0lNTwy01
1A1WSKQTWw0MoufwGO3Nb076ctZZes43z9u9ZGtIzhaG0pcb3EmPL1EPMm003L/b
p2rIoo75giQZ5xbiYVdOzihwbJJ/Abp8m7pXEpstXD7emNh4Gwid7gW5JxiBBhQm
1I6l7TbXswnT4jh35rrMcwoM7Jb0Z/gdCZSoHO1jfplZcCv2VVhH0+USqa/oBWlu
OZMPTYu7IU+nTMbxYb+bax7V7ZS+WSuVilUS36HpoKY5WpGnknLzyyv4+DF41LUF
m+WEeYnjm2WnSrKyz4ijNBLR7L1pLRrfjHdLGqWorjRbmdp8YqUiZpVx+tAFYb9a
fbixWnR0xXXxEW5DZ+AUTnZh8fM0fKiE+bsmGzQEM8cnpOB5CgvTCiIY7RzdQFWY
V+kkd1aky14UqvBmtgLA3JlcghqkLts/t9i4G69nrYpyXb+OCi14c1X33b3Q0EbX
NDTGqC4zXuPwsb+fIVlqPr75mUV6XIwreJJ/dOh+h8WtBqFvY2+rhVJjyulj2joh
ggXBxLz9HU8+CJCDc9yXCC87b+B/NNCDJWpHDgKs81gfk+318Fu841KCq+fJiJFd
Y1FowOpUqPJzw//+qZWq
=/zlx
-----END PGP SIGNATURE-----

--=-qQ8bFvbHOMiBf9zOd7O+--
