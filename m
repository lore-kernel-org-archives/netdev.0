From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: e1000: convert to build_skb/napi_gro_frags api
Date: Mon, 01 Sep 2014 17:30:59 -0700
Message-ID: <1409617859.2384.6.camel@jtkirshe-mobl>
References: <1409423307-23470-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5258686913584277027=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1409423307-23470-1-git-send-email-fw@strlen.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============5258686913584277027==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-avHCT87UPf5OGZj3Xh8b"


--=-avHCT87UPf5OGZj3Xh8b
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-08-30 at 20:28 +0200, Florian Westphal wrote:
> e1000 driver preallocates skbs, then sends them up the stack.
>=20
> This series changes the rx routine to only preallocate data buffers,
> then initialize skb right before passing it up the stack.
>=20
> This gives slight performance inprovements as the skb will be
> fresh in the cache once its allocated/initialized.
>=20
> The default-mtu 1500 path is converted to build_skb()/netdev_alloc_frag.
>=20
> Jumbo path is converted to napi_gro_frags.
>=20
> Note that this has only been tested with kvms e1000 emulation.
>=20

Can you re-spin the series with Sergei's suggest change for patch 7,
please?  I will await your v2 before picking up this series, thanks!

--=-avHCT87UPf5OGZj3Xh8b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUBQ/DAAoJEOVv75VaS+3O/BgQAKYLN69hINItJJEmXyVDwhz0
sTlVqa9u3cL4NtAg0sarzyw9I6SZpZTIaBnB4jMjbyNBhH2q75wDHaKhSWMd+BN1
fe7AZbKux4lVzlFQgoNMOrWMaj3X5hYI1djA2ROo/x1EbTwk4fhUsi3PhoaKk+tZ
1zZ4pHu7eFFl75G83PRryLAOHYk/u6QoWAca1TtIMoy2YMTiKjXq2pkQQoIeuAAJ
YfpHrW8Bo1UetafTwIO8A24mfh2qd4jizzMb6xDqsC9wwS8woHA95McJ9RpbIcDa
GOQkyAG+lgwIVCWoWfbjHdBm7A7JLG/QwL3QIHErCCKMf7BWBwh2tys6NnF1llc5
KOU3a2hlgkjUnTxTBt6Xb47blwdH8iNqHTspsyqqzkT2mDxvKXo10iShBDr+XEs9
g0F8scJVbS2DYFrvgvcZNnyCMGcJT57YDll3ZUUZpT6YdVnnm0DmgQwtartWfCPX
AfVrjiW+mVARzo+SufO8/QTGCCM3xGRraIU9G4P/YoeyfQcAaUtL618cG8+C+ziL
++WpVHwp7r782OAxQ/gSRGZAwEWW8u7KAScRS8SGHMdWipLKI/CeduA/UJKbbKvz
4etLWN9ad+Vjqg6HzdhijYPj1e7TZ/UKYUAh1qQlCciGrq+qRcIqoJBsgggr0PAQ
Tr9iwHNKvtieAW136nQx
=dlgU
-----END PGP SIGNATURE-----

--=-avHCT87UPf5OGZj3Xh8b--



--===============5258686913584277027==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
--===============5258686913584277027==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============5258686913584277027==--
