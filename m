From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac: turn coalescing / NAPI off in stmmac
Date: Mon, 5 Dec 2016 12:45:02 +0100
Message-ID: <20161205114502.GA16126@amd>
References: <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161130114431.GB14296@amd>
 <20161201.152303.425589678238707778.davem@davemloft.net>
 <20161201224827.GA26301@amd>
 <2ceae6dc-3a48-3212-c634-cc6f1f0b363f@st.com>
 <20161202104238.GA31172@amd>
 <9b338d9b-a69a-7393-0b48-bc6b92b46cb7@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="WIyZ46R2i8wDzkSu"
Cc: David Miller <davem@davemloft.net>, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9b338d9b-a69a-7393-0b48-bc6b92b46cb7@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >>>So patch currently looks like this (hand edited, can't be
> >>>applied, got it working few hours ago). Does it look acceptable?
> >>>
> >>>I'd prefer this to go after the patch that pulls common code to single
> >>>place, so that single place needs to be patched. Plus I guess I should
> >>>add ifdefs, so that more advanced NAPI / tx coalescing code can be
> >>>reactivated when it is fixed. Trivial fixes can go on top. Does that
> >>>sound like a plan?
> >>
> >>Hmm, what I find strange is that, just this code is running since a
> >>long time on several platforms and Chip versions. No raise condition
> >>have been found or lock protection problems (also proving look
> >>mechanisms).
> >
> >Well, it works better for me when I disable CONFIG_SMP. It is normal
> >that locking problems are hard to reproduce :-(.
>=20
> can you share me the test, maybe I can try to reproduce on ARM box.
> Are you using 3.x or 4.x GMAC?

I'm using board similar to altera socfpga. 3.70a, as far as I can
tell.

                gmac0: ethernet@ff700000 {
                        compatible =3D "altr,socfpga-stmmac", "snps,dwmac-3=
=2E70a", "snps,dwmac\
";

> >>Pavel, I ask you sorry if I missed some problems so, if you can
> >>(as D. Miller asked) to send us a cover letter + all patches
> >>I will try to reply soon. I can do also some tests if you ask
> >>me that! I could run on 3.x and 4.x but I cannot promise you
> >>benchmarks.
> >
> >Actually... I have questions here. David normally pulls from you (can
> >I have a address of your git tree?).
>=20
> No I send the patches to the mailing list.

Aha, ok.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--WIyZ46R2i8wDzkSu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhFUz4ACgkQMOfwapXb+vJ+QACdFp78V8FMWyz9DHJCjp2UI6a4
A3YAoL82Q/42ra80dXzutlNSgV6Vkd9p
=mTTf
-----END PGP SIGNATURE-----

--WIyZ46R2i8wDzkSu--
