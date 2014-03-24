From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] intel: Remove addressof casts to
	same type
Date: Mon, 24 Mar 2014 13:21:19 -0700
Message-ID: <1395692479.2899.2.camel@jtkirshe-mobl.jf.intel.com>
References: <1395683159.13968.60.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7028374437439087188=="
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>, linux.nics@intel.com,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1395683159.13968.60.camel@joe-AO722>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============7028374437439087188==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GivF/zph7+ij6bWng48B"


--=-GivF/zph7+ij6bWng48B
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-24 at 10:45 -0700, Joe Perches wrote:
> Using addressof then casting to the original type is pointless,
> so remove these unnecessary casts.
>=20
> Done via coccinelle script:
>=20
> $ cat typecast.cocci=20
> @@
> type T;
> T foo;
> @@
>=20
> -       (T *)&foo
> +       &foo
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_common.c   | 4 ++--

Thanks again Joe, I will add this to my queue.

--=-GivF/zph7+ij6bWng48B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTMJO/AAoJEOVv75VaS+3O6nsQAJR2TqovuyOLs/x2uSTO35Y4
0Csx45FrI7Po2T6mt2b4JKcbNpPz0f6lgA4igfwa5cJB8B2SYfiezxE7R78vpeYx
rEdjY9SWC8ipiz8RqBIh0X7zGZ/PICFbcVP1dAiClCzA0cmGo4chT7I3PNECOGme
EtKoZjji+et/njSsdqzOUc/0atV8TDDiEYxEvDUfSorDl6IjDryOXmOoR4eYZy+S
L242kbcthSny131DqKiFiOK9s8XC+TVQ1LNiWNLvGDe9i2MhgNZukQnBaLtno5Wp
KEVZsHss/3qgB5vcBPp+0zio1lxBWe1CV7SnLM6Fdggm5H/LcaT+xeRQGQHAFFPL
MUCBtVsL3KFhoWN6WKlfXZb4l0hDnZ2sAUqt9A+T0mVoziydosTmCkfDYGLunKCE
mO8QEPod1P7IAQk+qdYFLJ/eE0QdqkFMgH8xH201g8V1istHI87UIEW14cN7+wOU
WgpLZAwKDxGbBDNKr35Wd0+TsDzzbaWSh6Y7b3GZc6shFwu0anXHtUUrXYaokxFu
fs049JWzK6AZyHNW940qZxycrqVg7cS3k0dP7UAjpy9jhLJO6XRBgnomC1UvCTV0
oAzIvRvKBEGpGR8Plhlx9bKHVh7e0ElLujLIqm55Vhm9HP8LDnSINHcsR7DMJqRI
P+5rnsNJc3B0xyHdfn/7
=6q6+
-----END PGP SIGNATURE-----

--=-GivF/zph7+ij6bWng48B--



--===============7028374437439087188==
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
--===============7028374437439087188==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============7028374437439087188==--
