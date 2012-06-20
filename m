From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 20:26:04 +1000
Message-ID: <20120620202604.407af721f746045ae00c8268@canb.auug.org.au>
References: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au>
	<D5ECB3C7A6F99444980976A8C6D896384FAA275CA8@EAPEX1MAIL1.st.com>
	<4FE18502.6040409@arm.com>
	<20120620.012037.783895812206310043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__20_Jun_2012_20_26_04_+1000_Pt2R0QMfCktuvVXA"
Cc: viresh.kumar2@arm.com, bhupesh.sharma@st.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, federico.vaga@gmail.com,
	giancarlo.asnaghi@st.com, wg@grandegger.com, mkl@pengutronix.de,
	spear-devel@list.st.com, Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120620.012037.783895812206310043.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__20_Jun_2012_20_26_04_+1000_Pt2R0QMfCktuvVXA
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Wed, 20 Jun 2012 01:20:37 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: viresh kumar <viresh.kumar2@arm.com>
> Date: Wed, 20 Jun 2012 09:08:34 +0100
>=20
> > Please see following patchset from me, that got applied in linux-next
> >=20
> > https://lkml.org/lkml/2012/4/24/154
> >=20
> > Please check if this patchset is present in your build repo. I believe =
it should be
> > there. If it is, then you shouldn't get these errors.
>=20
> Well, then Stephen shouldn't get those errors either.
>=20
> But obviously he did.
>=20
> But all of this talk about changes existing only in linux-next is
> entirely moot.  Because The damn thing MUST build independently inside
> of net-next which doesn't have those clock layer changes.
>=20
> Someone send me a clean fix for net-next now.

I get those errors because those patches are in the akpm tree which is
merged after everything else ...

One possibility is to put those changes in another (stable) tree and
merge that into the net-next tree (and any other tree that needs it).
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__20_Jun_2012_20_26_04_+1000_Pt2R0QMfCktuvVXA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP4aU8AAoJEECxmPOUX5FESSkQAKpF+Pf7CDj+K4cG37IdcOeE
GZ7vji+MG9baDypNtp2CAPQOS2aYZeO4YBbBDg1UIDmDfltdi8iEpwpfPkIZDEzt
yIfUN2O4RgvQ/reoxtp9aJ8DKbdOK+eO+zA4h1fdDRzsLMGZO7aWQOv0LbnC0Prz
VX6nJHyloHsOWD3kX3e5j4Fq241EPR+sTC4DRnqMNI5esu1rwuNCx1TAPqVEO8xq
AlVpKoBV+MTICylBAwspdv8cr6o2hsz99szPHMRgRPZ30qvbkdx2to7xCvSj4wgb
76+Tj5gUZZ4aQMMRKKpGIp151NTZ1aD9Hlg24GcwmKJz21XAi8PTmWa/fptZ1EfO
HeE6RCwxsoDMhL+EKXd1gmunmzQTvzMqAQsJEHVGVEAYA/70M4+K8g0tlZmleM22
WuUITytjY/gWQDRo3dauRAvb2LlkbEGFPw8b+zyqj5I0VFEH6K+v7NSscuOmPsYV
RUuxwqMu+LHgjhp43n/i53eGxks4WDMSOz1uOc/3y7vVG5yNg5TxW/s+CX3NTq7p
rUqG91VC2I0Wym40lrQmVo/L5E2qEQioOzy+YROBQO5LPJzzVmCtjZImyc32jOzj
n/qXtP3gkjux3yQncUN70NH3Unm2eSVtUI6SxaABEjqXbQkNvuKO38YRFnhtU3Ol
2WfQVOxHGTEnwgzwnS+2
=keoq
-----END PGP SIGNATURE-----

--Signature=_Wed__20_Jun_2012_20_26_04_+1000_Pt2R0QMfCktuvVXA--
