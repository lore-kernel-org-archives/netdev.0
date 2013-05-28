From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 1/4] igb: refactor and simplify
 time sync interrupt handling
Date: Mon, 27 May 2013 17:44:20 -0700
Message-ID: <1369701860.2116.135.camel@jtkirshe-mobl>
References: <cover.1369645944.git.richardcochran@gmail.com>
	<e81791002acaf082ace4ec7bb1fa24ab6633fd49.1369645944.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7563778729771357615=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <e81791002acaf082ace4ec7bb1fa24ab6633fd49.1369645944.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============7563778729771357615==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jvgvIVFO/H6MSfGDcm97"


--=-jvgvIVFO/H6MSfGDcm97
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-05-27 at 11:21 +0200, Richard Cochran wrote:
> The code that handles the time sync interrupt is repeated in three
> different places. This patch refactors the identical code blocks into
> a single helper function. Also, reading the TSICR register already
> acknowledges the time sync interrupts, and so there is no need to
> write that register at all.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |   47
> +++++++++++------------------
>  1 file changed, 17 insertions(+), 30 deletions(-)=20

Thanks Richard, I will add this to my queue.

--=-jvgvIVFO/H6MSfGDcm97
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRo/3kAAoJEOVv75VaS+3OtkMQAJfkwJnXWvlC8/He5cnl/fPI
qhjcQiLvDtn/7Lq2Xtm+mqe/nuUaj3QDWJS+uYTFkA0t3AWqdhUJ3mMoZoM49iEk
8vNjH/Hw/5jP6qrre5PUfpxPgWg+cV8mh2+APmB26GTUf2YbXNR63NYnxS9470MR
unSZHbEoulwBONJtWLsFET+fd747DayI/KqHrqDz0xco6Li0iKs7JOGSyAdPYgb5
3lN1+eKRVvC8E/2SArdWZ9QAr0StfmKqbJMs4uq1iYOpgTg4nnb7saKQzcOgX6mJ
WuZqP6g8k8TZc2dG48Mi3KVr9bkbT0GelOWjFrOyJ6wxBmFppPVBdOIUWqb7Sw+q
zYfP4Esa6szxSYtDMPGCjrxsKqrRAKgln0VHLd6nWwLqy+MqSTtd/Snu1/OhXHqw
yOHfIsXBOpoUvD4FRHzXUoKt1L3pbJYmssgeCj6senVEIsiLl+MNDmI1nWDB7X3k
ENmyM2ywz9CeC6UbHyd5yH0dY7SC3c+QJdxoEloa+u7/pKFMQzxHKlaGzAJVI2Ok
cwqmGwC4v6Cvg6MGx0Fy2F3JA7eBNO9lx3sVfCAKlHAplG4OKzPxIoXXJNb/h6l4
Ng8mYrBPAuVWlnAqDc2jsAVaOjQRosEBTHDK3kBBiOgoMwCn+l310c5kJ9AQFmVt
nKX7Lk8oKeUDXOGrFOXY
=Pure
-----END PGP SIGNATURE-----

--=-jvgvIVFO/H6MSfGDcm97--



--===============7563778729771357615==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
--===============7563778729771357615==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============7563778729771357615==--
