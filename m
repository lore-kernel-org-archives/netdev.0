From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: linux-next: boot test failure (net tree)
Date: Mon, 22 Aug 2011 19:26:56 -0700
Message-ID: <1314066417.2128.215.camel@jtkirshe-mobl>
References: <20110822113032.15087c2e190e2b0c3ee7dfb8@canb.auug.org.au>
	 <20110823114011.a059aea0138b75bfa7eed1ce@canb.auug.org.au>
	 <20110823114129.ceb18da164bf7df3c145941b@canb.auug.org.au>
	 <20110822.191348.2099822249437201579.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-vI3u4LL8ZvB8+NGeDtWS"
Cc: "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mikey@neuling.org" <mikey@neuling.org>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"paulus@samba.org" <paulus@samba.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110822.191348.2099822249437201579.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vI3u4LL8ZvB8+NGeDtWS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-08-22 at 19:13 -0700, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 23 Aug 2011 11:41:29 +1000
>=20
> > On Tue, 23 Aug 2011 11:40:11 +1000 Stephen Rothwell <sfr@canb.auug.org.=
au> wrote:
> >>
> >> On Mon, 22 Aug 2011 11:30:32 +1000 Stephen Rothwell <sfr@canb.auug.org=
.au> wrote:
> >> >
> >> > Here's what I am applying as a merge fixup to the net tree today so =
that
> >> > my ppc64_defconfig builds actually build more or less the same set o=
f
> >> > drivers as before this rearrangement.
> >>=20
> >> And this today:
> >=20
> > And this:
>=20
> I'm starting to get uncomfortable with this whole situation, and I
> feel more and more that these new kconfig guards are not tenable.
>=20
> Changing defconfig files might fix the "automated test boot with
> defconfig" case but it won't fix the case of someone trying to
> automate a build and boot using a different, existing, config file.
> It ought to work too, and I do know people really do this.
>=20
> And just the fact that we would have to merge all of these defconfig chan=
ges
> through the networking tree is evidence of how it's really not reasonable
> to be doing things this way.
>=20
> Jeff, I think we need to revert the dependencies back to what they were
> before the drivers/net moves.  Could you prepare a patch which does that?
>=20

I was just finishing up those patches (not including any defconfig
changes) and started looking at a patch to fix/resolve the issues that
Stephen is seeing.

Let me see what I can come up with tonight to resolve this.

--=-vI3u4LL8ZvB8+NGeDtWS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOUw/wAAoJECTsCADr/EWU9q4H/3UFk+821Pdb0/jiVN0ve+ea
IAyxA4WfWT/9y4wW3FSoWGc2YXZygmtYMcSXxqMw4FTFeQbrvFNNRMG0pmklmnwM
dc6EQtjP2Zj23jGe4B/a06/XzsJj8ebsoR7/JW8cWrD3Nhcz8+pSxL9hij2tu/ML
JCZkmLMyYr5RjBZ6yE8f2ahIuAc/OKKlrrb7xyQz0f/Wgqt29Jif+EgSjlOIyVHO
/ud++xCdDbv/rdLEK8gpAiaxoTh+YhopPkt8cXQc6y77AF8L9pvSQ9s3BNerBzJo
ZxpQz1LBlM4K6femZzfAVUpSv0Y/37nwmLDcQoITkc700UinJEjxnsJ64QWHphs=
=ZIWS
-----END PGP SIGNATURE-----

--=-vI3u4LL8ZvB8+NGeDtWS--
