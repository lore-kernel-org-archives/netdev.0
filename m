From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] net: i40e: avoid unused function warnings
Date: Wed, 20 Jan 2016 14:17:25 -0800
Message-ID: <1453328245.2958.28.camel@intel.com>
References: <2806620.EpZqDlZTO3@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-s5QhU1CTDo2x34oynExZ"
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2806620.EpZqDlZTO3@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-s5QhU1CTDo2x34oynExZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-01-20 at 11:42 +0100, Arnd Bergmann wrote:
> The addition of the geneve tunnel offload code left a couple
> of functions unconditionally defined but empty whenever CONFIG_VXLAN
> and CONFIG_GENEVE are disabled. gcc warns about this:
>=20
> i40e_main.c:7049:13: warning: 'i40e_sync_udp_filters_subtask' defined
> but not used [-Wunused-function]
> i40e_main.c:8516:13: warning: 'i40e_add_vxlan_port' defined but not
> used [-Wunused-function]
> i40e_main.c:8561:13: warning: 'i40e_del_vxlan_port' defined but not
> used [-Wunused-function]
> i40e_main.c:8596:13: warning: 'i40e_add_geneve_port' defined but not
> used [-Wunused-function]
> i40e_main.c:8643:13: warning: 'i40e_del_geneve_port' defined but not
> used [-Wunused-function]
>=20
> This moves the #ifdef statements to the outside of the affected
> functions, which avoids the warnings.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 6a899024058d ("i40e: geneve tunnel offload support")
> ---
> This is a harmless regression against v4.4, found on ARM randconfig
> builds

Thanks Arnd, I already have a patch from Eric Dumazet and Alex Duyck to
resolve this issue.

Dave- I plan on pushing the fix later today to net.
--=-s5QhU1CTDo2x34oynExZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIbBAABCgAGBQJWoAd1AAoJEOVv75VaS+3OgFMP9imaog9xWoQ2bLzer5mKdVHH
9RI9jh9UejPDyhVUuCGiAzae411t025gqyadUhEcnvxUrI+lGiMgBBe2k//9a6JD
Zea4lDRDDdUSUBrunN/NpF8O8DVe9jiie7d7amRDoM13/Fr+p+Fizg7L+0i7a3R3
kwc36CIl3lZxq3Ov6Zv4XFG1evfUlXWgiuPr1S3quczEWyyE+q8XjhOuzyPWV+Z4
AWZ5AoD0B/LRLCeqyV/eSTT1/MwNgK9BfhmgBKh4Jg+NIxLYzUgQOcXPjm3p35d9
FACL3+nxbVPHITcyB4sEjynCTScWmL4aIay9VSbVzxTtSy/2c0rtWfMsVzL8WlS8
TL9rEFOL4zn+XYK3U0Jj5K8Y/SuMW/s8jq+IfhV6nFCzzjv12H3kL0lxpYFBWfj7
pYKhOxybO8yLhu1oQaK9aAHjMoMf2CXzm6AWESV/eTIgaz5PIadkyHYTs1+st5IS
UBn0ODdL+FgxtZLxTsPrHMqtMp9Jwz6v6TH5V5h9C5l5pNdExe9kSAH4xtcQPn8Q
TpTSY4YrRM0O6u+dmnsZCNIpfGhe+uO46vQlRWhiMxZ3iMdGzeVZRBR48RbJl5fd
oGHGFH4NZEH9TgIZ63qkXIVjTl1jFFg4pUijE4SCkGvjH0n6pD4pDFOgpLw+S2X4
BfPy0vmqeBSIXAvADbc=
=7EL8
-----END PGP SIGNATURE-----

--=-s5QhU1CTDo2x34oynExZ--
