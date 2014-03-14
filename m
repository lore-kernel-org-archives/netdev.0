From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 07/10] igb: never generate both
 software and hardware timestamps
Date: Fri, 14 Mar 2014 16:18:17 -0700
Message-ID: <1394839097.2167.93.camel@jtkirshe-mobl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	<1394818481-7652-8-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1861695429024708780=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1394818481-7652-8-git-send-email-kubakici@wp.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============1861695429024708780==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0qZQhsU6WtR7HynO8Q/n"


--=-0qZQhsU6WtR7HynO8Q/n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> skb_tx_timestamp() does not report software time stamp
> if SKBTX_IN_PROGRESS is set. According to timestamping.txt
> software time stamps are a fallback and should not be
> generated if hardware time stamp is provided.
>=20
> Move call to skb_tx_timestamp() after setting
> SKBTX_IN_PROGRESS.
>=20
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Thanks Jakub, I will add this patch to my queue.

--=-0qZQhsU6WtR7HynO8Q/n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTI445AAoJEOVv75VaS+3O2tYP/2Qrpr9ZXF5uxxIAp57sKOEF
39P3OZcLPvA+2rwmIqXHN7uzgex9HffZ8C1x7Ca0b/3bpj0VoVrrdxyISswVsmE7
719DKvejke3MCfLRqKRTUqjUaRwSCU4zOJu2Y0RaCGXK9prUGbQLf2nXsCnPa/MW
dJM+YBSUfRxWcEZvrqQ6EZ/etiLAuqlgUB0nGNbVp6rqjU1PyDcPCCRW++8O7nDz
90vW7D8qMZjnWU3OZmqrdjcQV6ef1L3ewIQpP3Xnuz35dnsr0cnbs/nJX8vJ1QXF
gtbRCRqagKvv0g5jk0OJSkhOH0fUozF7+9pp0OrfSBco7BYAGQl7+j8RgrmjeSDe
uvCWlX03KB+BAMjbqdgOJGviFYNWLuVcQILomE0oDNlrCfZK9cIQHCYZVK+yDD9x
8p6odqQhqkG1UtxLZuYOgBeYk3fu11hrNZ4j/WhkIkwnMrBJZrFng7rb3EWgD0gU
kChM8j284usWL3huU4n5TUKQ36VY9BnbmXtFnLnRyjqKl8xmaEmVOyIyrdO+eecm
QFDSq98vEDWYYlUVLCxS/koATavX/76etTlPt0UhcK1mdVpuwJSKWVWNuOxdJP+W
4pfP4keQA2ttR9YjhBx+aIbNWxzzS9vnoP63BsLjqVYfF5mDgfsMxa2T0ugj4Oby
QOZ/JvV+cWe1pjBZ+uii
=hjlh
-----END PGP SIGNATURE-----

--=-0qZQhsU6WtR7HynO8Q/n--



--===============1861695429024708780==
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
--===============1861695429024708780==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============1861695429024708780==--
