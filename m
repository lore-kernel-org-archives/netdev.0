From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 15 Mar 2011 11:30:49 +1100
Message-ID: <20110315113049.a6112494.sfr@canb.auug.org.au>
References: <20110314152456.b49b2693.sfr@canb.auug.org.au>
	<1300078778.3962.22.camel@localhost>
	<20110314163135.f366742e.sfr@canb.auug.org.au>
	<20110313.225312.193696949.davem@davemloft.net>
	<20110314170546.af552b4e.sfr@canb.auug.org.au>
	<alpine.LFD.2.00.1103141053020.2787@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__15_Mar_2011_11_30_49_+1100_edbgPSVLqaAkCy/j"
Cc: Thomas Gleixner <tglx@linutronix.de>, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, hpa@zytor.com,
	peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1103141053020.2787@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__15_Mar_2011_11_30_49_+1100_edbgPSVLqaAkCy/j
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Mon, 14 Mar 2011 10:56:12 +0100 (CET) Thomas Gleixner <tglx@linutronix.d=
e> wrote:
>
> On Mon, 14 Mar 2011, Stephen Rothwell wrote:
>=20
> > On Sun, 13 Mar 2011 22:53:12 -0700 (PDT) David Miller <davem@davemloft.=
net> wrote:
> > >
> > > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > > Date: Mon, 14 Mar 2011 16:31:35 +1100
> > >=20
> > > > Maybe some config option changed ...
> > >=20
> > > Perhaps GENERIC_HARDIRQS_NO_DEPRECATED?
> >=20
> > Yep, that has been turned on for powerpc now.  I guess you will have the
> > same problem on sparc64 of you merge the net-next and sparc trees ...
>=20
> Yeah, powerpc alone compiles with GENERIC_HARDIRQS_NO_DEPRECATED as it
> does not have that notify commit.
>=20
> If you add net which has that notify commit, but not the fix it
> breaks. I wonder whether Dave should pick that fix into net.

So, if you merge the commit 1fb0ef31f428 ("genirq: Fix affinity notifier
fallout") from the tip tree, you will get exactly one new commit and will
fix your tree properly with no adverse effect on anyone else.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__15_Mar_2011_11_30_49_+1100_edbgPSVLqaAkCy/j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNfrM5AAoJEDMEi1NhKgbs1hIH/R2B+1tFMRMT1S+inCilrv2Z
A89FIHGU4aWQBhgQgCLc7ks1xw49XVJyamysDlnagwhK+z3ouQxiahepHyUIkHWq
/eUqPAaEiFiECeHpLWBd8l3tTe1bUHt87RbYiDj/ocXUvsW07cTlxHjBd6/dgFIM
dblnofbn2Ao0qCbDUSsoR+3F6zvruvyDKQ0+1XWbxZffFQpWEYQa4IyZDRSEkNdW
gNtpZ27883FzzZZuwWupDzPMSNnAFe+eV1w6fwVYTz1Pr+vpoYe3QiTdKrKrgFJ/
Icka/zV6bwnoVzQgFtyX6O/pu1hpjCt8HtLg1C4SXVMq92W2ACV8ekytoxeSyCU=
=GaG+
-----END PGP SIGNATURE-----

--Signature=_Tue__15_Mar_2011_11_30_49_+1100_edbgPSVLqaAkCy/j--
