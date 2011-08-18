From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: linux-next: boot test failure (net tree)
Date: Wed, 17 Aug 2011 22:40:59 -0700
Message-ID: <1313646061.2128.82.camel@jtkirshe-mobl>
References: <20110817100146.3b557cf815a5a2ae09bc09a7@canb.auug.org.au>
	 <20110816.171525.639251389938336183.davem@davemloft.net>
	 <20110817105002.efebf85d08460ad99b14be8e@canb.auug.org.au>
	 <20110818152214.661858a61496993aaef2c704@canb.auug.org.au>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-kelnS9t5Oqi26QC82//l"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Michael Neuling <mikey@neuling.org>,
	Linus <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110818152214.661858a61496993aaef2c704@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-kelnS9t5Oqi26QC82//l
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-08-17 at 22:22 -0700, Stephen Rothwell wrote:
> Hi Dave,
>=20
> On Wed, 17 Aug 2011 10:50:02 +1000 Stephen Rothwell <sfr@canb.auug.org.au=
> wrote:
> >
> > On Tue, 16 Aug 2011 17:15:25 -0700 (PDT) David Miller <davem@davemloft.=
net> wrote:
> > >
> > > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > > Date: Wed, 17 Aug 2011 10:01:46 +1000
> > >=20
> > > > In particular, CONFIG_TIGON3 newly depends on
> > > > CONFIG_NET_VENDOR_BROADCOM which will no be selected when doing a
> > > > "make oldconfig" from a working config.
> > >=20
> > > When you type "make oldconfig" with an existing .config it prompts yo=
u
> > > for those vendor guards, giving you ample opportunity to say yes to
> > > them.
> >=20
> > Which is a bit of a pain for automated systems.  Ours does (essentially=
):
> >=20
> > yes '' | make oldconfig
> >=20
> > We really don't want to select every new config item that comes along.
>=20
> So, Mikey did a test for me (he was bitten by this today).  Just one of
> the powerpc configs (pseries_defconfig which should, in theory, build a
> kernel that will boot on almost all our POWER server machines) loses all
> these drivers if you do a "make pseries_defconfig":
>=20
>  -CONFIG_IBMVETH=3Dy
>  -CONFIG_PCNET32=3Dy
>  -CONFIG_E100=3Dy
>  -CONFIG_ACENIC=3Dm
>  -CONFIG_ACENIC_OMIT_TIGON_I=3Dy
>  -CONFIG_E1000=3Dy
>  -CONFIG_E1000E=3Dy
>  -CONFIG_BNX2=3Dm
>  -CONFIG_CHELSIO_T3=3Dm
>  -CONFIG_CHELSIO_T4=3Dm
>  -CONFIG_IXGBE=3Dm
>  -CONFIG_IXGB=3Dm
>  -CONFIG_S2IO=3Dm
>  -CONFIG_MYRI10GE=3Dm
>  -CONFIG_NETXEN_NIC=3Dm
>  -CONFIG_QLGE=3Dm
>  -CONFIG_BE2NET=3Dm
>=20
> That is just one of our deconfigs ... there are over 400 defconfigs in
> the kernel and a lot of them will need to be updated.
>=20
> Mikey asks:  Will Dave take these updates if we get Acks from the
> maintainers?  :-)
>=20

I am open to the idea.  I considered updating the the defconfig's, but
was not sure was the best way of doing the changes.  I was not sure
making these changes in Dave's net-next tree would not upset the arch
maintainer's, especially if there is a better tree(s) for the changes.

I am in the finishing up the patches for drivers/net/ {FDDI, PPP, SLIP,
HIPPI, etc.) and since I started this change, I would sign-up for making
the defconfig changes if that helps.

Cheers,
Jeff

--=-kelnS9t5Oqi26QC82//l
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOTKXrAAoJECTsCADr/EWUJiIH/0ROZMDOoPSQ7FKBwlLItjk0
lkKlQJ2Yf34W5JDw2Bottcb22JedeHf22O9638ovVxicMHnAyJKhRDSq1qW//e5I
0J9MYDaOi4vXOzL+7bavLdSMvGzNkvXaPGqhqhqEA1APtiJRiAmKRN0tUgMnjPNO
8Cfpg0lOPkaLU0gaBSmc499wC4v5DITIFTdEoaMnRF2smhqTZf1uFfT8pI1uOWhc
YfCDY5SkhhkrClwTHtN1ilE8YW5BQtZINhYt63eJLFZ/KVdCA3ac/7xIpowC/o45
z4VA+ozT/+7Nfi39QG1bWk82mocowdquQuXC+ZAUI/cvLS1fI6yz0ivza+fGanI=
=g310
-----END PGP SIGNATURE-----

--=-kelnS9t5Oqi26QC82//l--
