From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [RFC][PATCH] x86: remove vmalloc.h from asm/io.h
Date: Fri, 29 May 2015 22:40:06 +1000
Message-ID: <20150529224006.23096056@canb.auug.org.au>
References: <20150529191847.2d4cb3a7@canb.auug.org.au>
	<20150529092105.GA30603@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/m2oxYVLmcp9uyI4uBDEUKwI"; protocol="application/pgp-signature"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Anton Vorontsov <anton@enomsg.org>,
	Colin Cross <ccross@android.com>,
	Kees Cook <keescook@chromium.org>,
	Tony Luck <tony.luck@intel.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>,
	Kristen Carlson Accardi <kristen@linux.intel.com>,
	Viresh Kumar <viresh.kumar@linaro.org>,
	Vinod Koul <vinod.koul@intel.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Hiral Patel <hiralpat@cisco.com>,
	Suma Ramars <sramars@cisco.com>,
	Brian Uchino <buchino@cisco.com>,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.d
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20150529092105.GA30603@gmail.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/m2oxYVLmcp9uyI4uBDEUKwI
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Ingo,

On Fri, 29 May 2015 11:21:05 +0200 Ingo Molnar <mingo@kernel.org> wrote:
>
> Good idea.
>=20
> Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks.

> Please also test x86 allnoconfig and defconfig 32/64, that tends to unear=
th the=20
> remaining places. People doing randconfig testing will find the rest.

Good idea.  the allnoconfigs produced this further patch.  I will
squash it into the original.  The defconfigs built ok.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 29 May 2015 22:01:41 +1000
Subject: [PATCH] x86: more fixes for removing vmalloc.h fron asm/io.h

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 arch/x86/include/asm/io.h | 1 +
 include/linux/io.h        | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 5791e7ace9db..2a3543a4db1d 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -40,6 +40,7 @@
 #include <linux/compiler.h>
 #include <asm/page.h>
 #include <asm/early_ioremap.h>
+#include <asm/pgtable_types.h>
=20
 #define build_mmio_read(name, size, type, reg, barrier) \
 static inline type name(const volatile void __iomem *addr) \
diff --git a/include/linux/io.h b/include/linux/io.h
index 986f2bffea1e..cb753a2450b8 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -19,6 +19,7 @@
 #define _LINUX_IO_H
=20
 #include <linux/types.h>
+#include <linux/init.h>
 #include <asm/io.h>
 #include <asm/page.h>
=20
--=20
2.1.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/m2oxYVLmcp9uyI4uBDEUKwI
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVaF4rAAoJEMDTa8Ir7ZwVyUsP/3lsZTXAKBUx1B+VSbd52xKZ
czRQM69RveRyZOGZiE0EMloECrKUtAOdtWfaEgjswg1RMgy56thrKhmh5WOtzZrO
UjuYr8Fm68G8b0YCLRpQtYQpAC60hMAMktHo42cjIXgEXkdlCwgmACDWFqo513Ly
PR1vK2Kl4XWIrPxJhGZ7OgtOJw2K+vK+UWHdyBVWxNlRC4xuWwVjHcipGWKVn3/G
6Go0H3DeER82IajdGPfS5Tz54YaPEtGguWfeslyIih0C1va3EOQG8adnqlvbL1m7
u3FW23yCCHZSMsl58tc/1g/YzSL03zE3UWYNeiTPqV2HjHYjzzba7VIQlW2STIzS
Nwfy8affcs2I50EOFO3Ywox5MChPjCmRHkZTnSuVwAtxNFxzBQy5LyKjWgzxDqiU
YpNoLFASZ4Z2eIKb4QkeRxarzE8gVM4Y8JTCJXX0T6FQZfQsB2cahpTucgY/9KEK
FQ3FSCl1vprDj9qWpYrkLaXefNF3G2JGE7IhbzDCuuyMAVROvLY1B3ZGmzeeE0Tn
/jacO3VRoCODQ5NmvCv50UtEog6Yx9dTOWco0nE7wJt2rLsVb8c/c7McJOwmpu7P
I3apK9RHmeK5YKXOAvYEdEYvqKXrS2FU3KRdwRGdxD9ADbOP/o1hcD28FOg5eB/k
5sODwUNoWjP8B4FAm3GV
=DvK0
-----END PGP SIGNATURE-----

--Sig_/m2oxYVLmcp9uyI4uBDEUKwI--
