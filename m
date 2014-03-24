From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 3/7] intel: Remove casts of
	pointer to same type
Date: Mon, 24 Mar 2014 13:20:50 -0700
Message-ID: <1395692450.2899.1.camel@jtkirshe-mobl.jf.intel.com>
References: <cover.1395692043.git.joe@perches.com>
	<9e1ace2dfe6b14005e66c914b4905efb3eadd18e.1395692043.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3347539420748860933=="
Cc: Mitch, e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <9e1ace2dfe6b14005e66c914b4905efb3eadd18e.1395692043.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============3347539420748860933==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QwY+dusQWyT9ZYPZ4MmC"


--=-QwY+dusQWyT9ZYPZ4MmC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-24 at 13:15 -0700, Joe Perches wrote:
> Casting a pointer to a pointer of the same type is pointless,
> so remove these unnecessary casts.
>=20
> Done via coccinelle script:
>=20
> $ cat typecast_2.cocci
> @@
> type T;
> T *foo;
> @@
>=20
> -       (T *)foo
> +       foo
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Thanks Jow, I will add this to my queue.

--=-QwY+dusQWyT9ZYPZ4MmC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTMJOiAAoJEOVv75VaS+3OHV8P/AsHgNf//X41XFI/WN+D4Cgf
boai67KNcEH+Dg6VRzFtqhPr/1zCwL0rxlyAXx+syyJluyBuuiMewO8QXAI+iUw5
KYhji1fR7irNr6XNu6hciPnzQ5dm1qU0+o9K69NITJNG2ARgiPUPNLrhJTn/Qe08
ocJ98uzVGxGh0NTcIstI6dyAfdPbIGtrTt38fzR3qigeQlLauCy/3mjxH2PAv5Kq
/1T0WVXT70yTTmq/9MU6XVv35PQMOSeeGwYPwUq4y7AsffDA+ve+AVRNTERYitAJ
gvsNI1HN0TCdgrD8WOGzfNmTHlj5BRYpGtHskcMNMk9UzcwTUgwMarqUKqHVpv2t
bJ+ITXyFrCvPAFbunxACJj0z4NilQfOcPmwzPX80+mrkOncic/RqhbheCEszYZBb
Zxz3zqEsRr0MxDxBfAI8oKwGFBIHmv82RV7aRO9k0QydRU9ijZtEme7fAEPZO5Bz
Wn4SuBH89e6aAJSa8leRaTt/3JK8gdzBHD0gAcnDvUJqNBGm8W/9JALChjVUOLxO
ineInuXMZas3O0USdCx4Z9yCTsBJBy7GpBbWqvVEvQ/oGWJrLkV8YIELX0g8KlCh
Sv68GIUqb1zgzeEkRY7LNf1P7s1UJ9zNln2bq5rXPJ6/6/RxnMV38nWbvFoK2pSc
NkbSN25hbNYgynQC2WUN
=vH7x
-----END PGP SIGNATURE-----

--=-QwY+dusQWyT9ZYPZ4MmC--



--===============3347539420748860933==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
--===============3347539420748860933==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3347539420748860933==--
