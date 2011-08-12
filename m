From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [net-next] spider_net: fix compile issue introduced by driver
 move
Date: Fri, 12 Aug 2011 14:41:31 +1000
Message-ID: <20110812144131.59de312ee6e1a9e8865c1a85@canb.auug.org.au>
References: <1313120000-12085-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1313120415.2029.3.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__12_Aug_2011_14_41_31_+1000_KN+sLlX/IyMcCdp_"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1313120415.2029.3.camel@jtkirshe-mobl>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__12_Aug_2011_14_41_31_+1000_KN+sLlX/IyMcCdp_
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jeff,

On Thu, 11 Aug 2011 20:40:14 -0700 Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
>
> On Thu, 2011-08-11 at 20:33 -0700, Kirsher, Jeffrey T wrote:
> > Both Spider net driver and Sun GEM driver use the sungem_phy.o object.
> > This fix creates a Kconfig object for sungem_phy (like MDIO) so that
> > both drivers require the SUNGEM_PHY object.
> >=20
> > This has been compile tested for the Sun GEM driver.
> >=20
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  drivers/net/Kconfig               |    4 ++++
> >  drivers/net/Makefile              |    2 +-
> >  drivers/net/ethernet/sun/Kconfig  |    1 +
> >  drivers/net/ethernet/sun/Makefile |    3 ++-
> >  4 files changed, 8 insertions(+), 2 deletions(-)=20
>=20
> Stephen, is it possible for you to try this patch to ensure it resolves
> the compile issue you saw for the Spider Net driver when merging with
> David's net-next tree?

That patch doesn't come close to applying to the copy of Dave's tree I
have from this morning (head e7c379d2a0dc).  I'll see if I can figure it
out ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__12_Aug_2011_14_41_31_+1000_KN+sLlX/IyMcCdp_
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJORK77AAoJEDMEi1NhKgbsuLIIAKI63wjx/RW+d64blazn6Utv
Rwc47MnBzgLcgzBQt46aDpmJ6YUY3evbHMO+PassKQSMslkn5dGJtSTfYQmNiVBD
DBMHjnCGPvBCVBwbyF4NcbZajKXcAAtmc7E9I6znyqdIwuc+duJi8Ny0fSxX2VWC
2oqJRuIuhDLfOZccSd0BYdjVR/ovAbXrGzQWceBstyjXdk+duvLeuHBpIv9XOlq6
A9CD+05Jq3X3/UoOejKWSLYvQUAtXMwVYm6cHCPiC6kzVCNYEajuU8lVYy0en3NB
OwuQIJyXtMHoKD7o3X2SaLRZsDOXC75krdmhJKXvW1X7+1bYhX31kYzgb2ILWi0=
=HK2R
-----END PGP SIGNATURE-----

--Signature=_Fri__12_Aug_2011_14_41_31_+1000_KN+sLlX/IyMcCdp_--
