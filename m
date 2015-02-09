From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] net:ethernet:intel:Remove outdated fix me
 comment in the function, gb_acquire_swfw_sync_i210
Date: Sun, 08 Feb 2015 17:26:07 -0800
Message-ID: <1423445167.2589.167.camel@jtkirshe-mobl>
References: <1423372910-29183-1-git-send-email-xerofoify@gmail.com>
	<1423444889.2589.165.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2272377998520390568=="
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1423444889.2589.165.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============2272377998520390568==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-J73cGSNGILhDp5LIpquu"


--=-J73cGSNGILhDp5LIpquu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-02-08 at 17:21 -0800, Jeff Kirsher wrote:
> On Sun, 2015-02-08 at 00:21 -0500, Nicholas Krause wrote:
> > Removes the outdated fix me comment in the
> > function,gb_acquire_swfw_sync_i210
> > for setting the variables, i and timeout to the intended correct
> > values for
> > the function,gb_acquire_swfw_sync_i210 to function correctly. This
> > comment is
> > no longer due to these values having been no changed in the last few
> > years and
> > no known issues have been found for these variables being set to their
> > current
> > values. Due to this the comment can now be removed as the values set
> > for these
> > variables are known to be correct after years of no known issues or
> > bugs related
> > to their current values.
> >=20
> > Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> > ---
> >  drivers/net/ethernet/intel/igb/e1000_i210.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> Thank Nick, I will add your patch to my queue.

Oh and the title should be "igb: Remove outdated ...", not
"net:ethernet:intel: Remove ..."

--=-J73cGSNGILhDp5LIpquu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU2AyvAAoJEOVv75VaS+3OP1AP/10eAvPDJRsjXNBx0JAm/fmP
60q4EiIFxDyjKF6I28rWql0tUoHksw58jExWp11SG2jaGeGTM0u3QUjXvCQwrKMO
2Sn9deUhOTsd9YI9JSHN+CHpHNSTVtY+LCJ+eMaP6qYH+rOD8eqWc54m9mG29Qdy
9sGZSV8c9hl7T9zyKUM4dkG00RQi5j8SMNX3p3j892keE3oUuY/MChuc152a1HCF
sM3wxqHObW6uZ8/MqMPBtFR3uJ1dVI9EH2g0P5J7cqNwJDVjGASQID4FMLKW+Kvp
/GkxOvIlJjSEwNnius2SbKtTH16u8qQAxV3fg/WshpK/uYGBE6SU2dGXx9l8ay/U
YWY4Lj3K2GFfPlJw/wwyZuBATabAMGpu+YFsif38xO+OpWAMT3icAbJ98dHy7im5
mdq96+aM9T/snF4CC9wazlOmn6lq5V0AzhoJYmrUDSZeCXES2A2ByCGQzAk9g98s
c0BYK0LpcEI67BJspWqo7sB+CHsUVrSAT1b3+UkGmU4WLIR0Cxq12L08lrlfTv1w
cJWfu3X8yK3G8bXuc/Dkjx4vQYAonLNxt1w7/NiHT6AgOamB0Y2IH34JxIVGBjLL
cbPJ3R3kQpKl8jkXavtXRkocyQXUaR6gyph77SylKqIwjbY22vErGeBeCxeNUJ4Y
/V7OTV2upjpwAKFIi3VO
=Api8
-----END PGP SIGNATURE-----

--=-J73cGSNGILhDp5LIpquu--



--===============2272377998520390568==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
--===============2272377998520390568==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============2272377998520390568==--
