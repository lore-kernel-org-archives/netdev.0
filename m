From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v12 01/13] sk_run_filter: add support for custom
 load_pointer
Date: Fri, 2 Mar 2012 14:10:38 +1100
Message-ID: <20120302141038.aaafc42b59ac7cf95d3553ed@canb.auug.org.au>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
	<20120301233712.GS3990@outflux.net>
	<20120302114705.0a9542e138927897f16282ca@canb.auug.org.au>
	<CAGXu5jL0OXR5MOePFe=GT4_X5rdH8RNjQPqYXdbqsqfijUsEqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__2_Mar_2012_14_10_38_+1100_iimP6pwrK=tATLVh"
Cc: akpm@linux-foundation.org, Will Drewry <wad@chromium.org>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jL0OXR5MOePFe=GT4_X5rdH8RNjQPqYXdbqsqfijUsEqA@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__2_Mar_2012_14_10_38_+1100_iimP6pwrK=tATLVh
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kees,

On Thu, 1 Mar 2012 16:57:49 -0800 Kees Cook <keescook@chromium.org> wrote:
>
> Unfortunately, yes, it does -- there were both ptrace changes and prctl c=
hanges.
>
> And at least the ptrace changes are, IIRC, in -mm, which has no tree.
> :P Given that, what's the best thing for me to do for this to be easy
> for you to pull?

Does this set of patches *depend* on functionality provided by those, or
just produce conflicts against the other changes?  If it is just
conflicts, then base your tree on Linus and I and (he when it comes to
it) can fix the conflicts as needed (with some hints if you think it is a
good idea i.e. is the conflicts are particularly complex).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__2_Mar_2012_14_10_38_+1100_iimP6pwrK=tATLVh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPUDouAAoJEECxmPOUX5FE+FgP/2ciSTssakN+2+OPgebOgSZE
kheNauQ21xKq5ADFPJ7rOhG5IBwrQAxrkBjfa79jwQq4pwIQTbi86leCazu6p/8R
jZxC+fH7qDbMyhfcP3TnA4y/DuFni/7IhbStaA6naj8qLHgHzn1O5/aSgBngFPV5
gfK9G58ZalygySgw21amEW2WUk4+b8GcnUOnI3suqSTBwqgw7Etke8QXXrca+WOn
al/40C5H1HH/gMmfA65ClmgKdZO5gruz+jtraaopFc43dVxgxUlrk497O8bkDyxw
aO5/WpgmJl3lLxoBtat6Is91AvJga1FaLUH/b9dJGXeipVdbU+9g+CfG4PBC9KVW
ltydGrJiuuaKO+pnMhcpe2WM3UEmX/vX6s+wn2XfUjIuwUEmVg7upo78suCKfLG/
YToUv+uZlsgDrWK7eDPy2OvoidroRRs5j5U7lut7DsA0nJlo/EZfpaAs+KrmGZjJ
u6vUm5Su4BisU9hihrT97ytlQfpyuWezX019M1btSHRhJiEsdwtuB1zPedNMw1/6
GnSsEkvxDPMfASIj4X23KVeioext4ZsV9WCI7nxmj1f/9FdMnpYSFJv+wEB5bPs0
0dsWzVMWAXTSKsAQcfvlzSm/LNFNIoE4Ne37/Spu1uNHJlsMr2C+fhpz5uXHNmhP
uGdv7WPzJgOV2rnjYaEa
=/L5q
-----END PGP SIGNATURE-----

--Signature=_Fri__2_Mar_2012_14_10_38_+1100_iimP6pwrK=tATLVh--
