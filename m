From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Mon, 14 Mar 2011 15:24:56 +1100
Message-ID: <20110314152456.b49b2693.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__14_Mar_2011_15_24_56_+1100_FzgnEkGE9v5sPp+n"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__14_Mar_2011_15_24_56_+1100_FzgnEkGE9v5sPp+n
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

kernel/irq/manage.c: In function 'irq_affinity_notify':
kernel/irq/manage.c:182: error: 'struct irq_desc' has no member named 'affi=
nity'

Caused by commit cd7eab44e994 ("genirq: Add IRQ affinity notifiers")
(which is also in the tip tree).  I am guessing that there is a fix for
this also in the tip tree ... yep commit 1fb0ef31f428 ("genirq: Fix
affinity notifier fallout").

I tried using the net tree from next-20110311 for today but that had the
same problem.  So I merged the above fix commit from the tip tree.

I have no idea why this has suddenly become a problem in the net tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__14_Mar_2011_15_24_56_+1100_FzgnEkGE9v5sPp+n
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNfZiYAAoJEDMEi1NhKgbs+DAIAIOgo7NgsH5GEsKVOtFodbSM
Amykwyyxypt7reVWKUREs+VvnD/BVmjgZNJyGgwGzjgeNup8KwtM0fFuLWnu10A8
4oaXMVq57gKb3ac6gI/7k/OzxsqBgCCKIyzpVErniLcRIKExfDnIpQABXOkZddNy
aoDkKbsHKmid+/aecMgHs18cF3eBb7jVagegWIpemzgW7rYagJTZzcICZFfxOurq
DpnQVAznb7uJu+HOtf2OMzr2Jiy7JGrZK9ld6sTIOODpoVKrBx25bxee3tQZk7Tz
B6DcYwvWZ08YhLJqR4309mZXCYkBOeewyHDXNn7nO/BDmVqsMtQBP8926yTt1E8=
=58DL
-----END PGP SIGNATURE-----

--Signature=_Mon__14_Mar_2011_15_24_56_+1100_FzgnEkGE9v5sPp+n--
