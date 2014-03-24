From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] i40e: i40evf: fix error checking
	path
Date: Mon, 24 Mar 2014 13:21:48 -0700
Message-ID: <1395692508.2899.3.camel@jtkirshe-mobl.jf.intel.com>
References: <1395606418-22964-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2416134098678816605=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org, Mitch
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1395606418-22964-1-git-send-email-sakiwit@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============2416134098678816605==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Fc/or9XkPTRhF4A9ZTKL"


--=-Fc/or9XkPTRhF4A9ZTKL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-03-23 at 14:26 -0600, Jean Sacren wrote:
> The commit 6494294f277fd ("i40e/i40evf: Use
> dma_set_mask_and_coherent") uses dma_set_mask_and_coherent() to
> replace dma_set_coherent_mask() for the benefit of return error.
> The conversion brings some confusion in error checking as whether
> against DMA_BIT_MASK(64) or DMA_BIT_MASK(32). For one, if error is
> zero, the check will be against DMA_BIT_MASK(64) twice. Fix this
> error checking by binding the check to the pertinent one.
>=20
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> Cc: Mitch Williams <mitch.a.williams@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c     | 11 ++++++-----
>  drivers/net/ethernet/intel/i40evf/i40evf_main.c | 11 ++++++-----
>  2 files changed, 12 insertions(+), 10 deletions(-)

Thanks Jean, I have added this to my queue.

--=-Fc/or9XkPTRhF4A9ZTKL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTMJPcAAoJEOVv75VaS+3OP7oP/jfLC3AenX6/1QGyrBSCRpN+
rXxiKUUFYCLzIK3AyxgtGj5IY4cx2trihiuKmZcBMj551LBpWn5Gf49xg8dKO1K4
uPOe92SClbwjycoX03Z+y+wz0qPh/jcOm3Pml03A/dKo2Uinnpi5U96rU7ydcQD7
222PxIhkxx+fK16RfWVo91rbrn8/geiCi1PWsyUbSJ6Vixz59keTte6L5IpgV4AG
w1pnPvkEJH8FE3ZPfySlTvUExX9JtEI5JkN/4ZDJlL1L1w8OAz9K0iZYoW1PeZpO
N6t16EkX9b41vmtiUSnZPZ/N4xeWmI786fS1bVBFedAkZuOWaq8/o3MxmotI551d
q5rt/AMffXb69r1d+37D7zGn0WOePvLPS3qmdEIAo1qsGOpXtCeW1YHneYyW8r/N
1nZ04FTUhowkq6tBaki/NHl7GRNyUVY8ijhIBouEe0DjTsdACwcAks9PfcQFfedJ
Bs3NnQdG+Qg9RqTIapzXZ1at9zRui+OF0yWsDjmUSZXTMMncSBaWXe9dujOvZTza
t7BO1TcikKZYQaOdtG8SbAzE95ZCxHm8UcZPQ7GLPbOW4SgKckNdHO4bnclPgWm7
5cp5GO6zSWnWGPXML2xCxygzTyRJvucwPQakZKgzAmMugu7SdYpSFTEcLrHtmyvy
UW29sZp+z1E2SzmCMmea
=pkBJ
-----END PGP SIGNATURE-----

--=-Fc/or9XkPTRhF4A9ZTKL--



--===============2416134098678816605==
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
--===============2416134098678816605==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============2416134098678816605==--
