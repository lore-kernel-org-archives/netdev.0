From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Fri, 21 Sep 2012 08:15:31 +1000
Message-ID: <20120921081531.67db8a7d0ac1b35426b22c45@canb.auug.org.au>
References: <20120920173622.2aa7209cd241a3945f4384d4@canb.auug.org.au>
	<20120920091013.GV15548@intel.com>
	<20120920.164558.2281417114805373564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__21_Sep_2012_08_15_31_+1000_T+/kma/tBQb0KTQc"
Cc: David Miller <davem@davemloft.net>,
	mika.westerberg@linux.intel.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	<linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120920.164558.2281417114805373564.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_Sep_2012_08_15_31_+1000_T+/kma/tBQb0KTQc
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[Just bring this to the attention of the PowerPC folks ...]

On Thu, 20 Sep 2012 16:45:58 -0400 (EDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Mika Westerberg <mika.westerberg@linux.intel.com>
> Date: Thu, 20 Sep 2012 12:10:14 +0300
>=20
> > On Thu, Sep 20, 2012 at 05:36:22PM +1000, Stephen Rothwell wrote:
> >> Hi all,
> >>=20
> >> After merging the final tree, today's linux-next build (powerpc
> >> allyesconfig) failed like this:
> >>=20
> >> drivers/net/ethernet/i825xx/znet.c: In function 'hardware_init':
> >> drivers/net/ethernet/i825xx/znet.c:868:2: error: implicit declaration =
of function 'isa_virt_to_bus' [-Werror=3Dimplicit-function-declaration]
> >>=20
> >> Caused by commit 1d3ff76759b7 ("i825xx: znet: fix compiler warnings wh=
en
> >> building a 64-bit kernel").  Is there some Kconfig dependency missing =
(CONFIG_ISA)?
> >=20
> > If we make it dependent on CONFIG_ISA then the driver cannot be built w=
ith
> > 64-bit kernel. Then again is there someone running 64-bit kernel on Zen=
ith
> > Z-note notebook? From the pictures it looks like very ancient "laptop".
> >=20
> > An alternative is to make it depend on X86 like this:
>=20
> I think the powerpc port is at fault here.
>=20
> Part of being able to advertise ISA_DMA_API is providing isa_virt_to_bus(=
).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__21_Sep_2012_08_15_31_+1000_T+/kma/tBQb0KTQc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQW5WDAAoJEECxmPOUX5FEfUAP+wVDkkqTUK3PovWOuIcr4Rfm
e8QLESS1lmjcsG0chwzDedjRfvGsI3F7s5lEqfCYunbBpN8iYMvmNdgsG81UKeO0
BccfUKFazdNzwwTYI6ylueJ3iAokuxfgoEIYDYitaXx/xiWEcPc1Sm6O+uZgN6o4
3riifaSjuUjPADLPaN21HqPVBWQwWU78lVLChaS4hazWNk4uXBxmLgFQeidzBW9r
LDJple2qC5WCv40hzFH4Y+DAnFyUxKowjg9Zj4I2YXKkvNT/2sSYpLIFhlWwaVWC
kSvNxa9It2KaUa5Q/qMzI8w2rJ/OUG7GeEQCFB2fcVqrK2d0tUbbELvxzf96SPzF
ScwNfxJZZg/FOhVa1VLsrQ/qb6wYVal7aO/KMH9vnutiBxciIQ1UCRUN4s0Ji9Qq
0uH2LwA1tFdVELQVn7lpB6grrR5DlZhr3l8XDfn7MNEUEnNeCnMQ8qNbgfgn0YMf
2fcFg44aZ75Upq3Pl1e3p1Utl3qcnbN5+OkJaFDwXRku2rBZwuxgQLQ3PB39jUG1
zCcrchLm0QZcvPNSlvyK8KYRMg5RegL9tj6VCGwPdbSzOa1pSxCtQjbvGVG2Noj3
ytP+Jyjw1fYbnkt+YtO/D4YBIkFI4FTtJausblpOIsXJqqM13I3G/VSCZYIZbtVG
26umyeOvJA0YGvqatENU
=Rw0G
-----END PGP SIGNATURE-----

--Signature=_Fri__21_Sep_2012_08_15_31_+1000_T+/kma/tBQb0KTQc--
