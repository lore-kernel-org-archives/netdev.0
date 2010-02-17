From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after final merge (net tree)
Date: Wed, 17 Feb 2010 17:40:15 +1100
Message-ID: <20100217174015.d1a8a478.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__17_Feb_2010_17_40_15_+1100_A=5+XS9VyLjzW5wp"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Engelhardt <jengelh@medozas.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__17_Feb_2010_17_40_15_+1100_A=5+XS9VyLjzW5wp
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging, today's linux-next build (sparc64 defconfig) failed like
this:

In file included from include/linux/netfilter_ipv4/ip_tables.h:29,
                 from arch/sparc/kernel/sys_sparc32.c:47:
include/linux/netfilter/x_tables.h:525: error: expected declaration specifi=
ers or '...' before 'nf_hookfn'

Caused by commit 2b95efe7f6bb750256a702cc32d33b0cb2cd8223 ("netfilter:
xtables: use xt_table for hook instantiation").  Missing direct include
of linux/netfilter.h?

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__17_Feb_2010_17_40_15_+1100_A=5+XS9VyLjzW5wp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkt7j08ACgkQjjKRsyhoI8yVpQCfXIFaSl3U6IN1qhWW5vq92CWC
EwsAoK47Hpzl3pTvEyUl5wP9yDzd/RvG
=/ab6
-----END PGP SIGNATURE-----

--Signature=_Wed__17_Feb_2010_17_40_15_+1100_A=5+XS9VyLjzW5wp--
