From: Mark Brown <broonie@kernel.org>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Sun, 24 Apr 2016 23:59:38 +0100
Message-ID: <20160424225938.GJ3217@sirena.org.uk>
References: <20160413175028.5d3a4cf2@canb.auug.org.au>
 <20160413.111513.295841881765244758.davem@davemloft.net>
 <20160422092017.GY3217@sirena.org.uk>
 <1461367243.3018.42.camel@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="pqRbAPYjtlk7lrMB"
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, mark.d.rustad@intel.com,
	andrewx.bowers@intel.com, kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461367243.3018.42.camel@intel.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--pqRbAPYjtlk7lrMB
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 22, 2016 at 04:20:43PM -0700, Jeff Kirsher wrote:
> On Fri, 2016-04-22 at 10:20 +0100, Mark Brown wrote:

> > > Jeff, please have your folks look into this.=A0 Probably just a
> > simple
> > > conversion to mdelay().

> > This is still present, it's been breaking ARM allmodconfig builds for
> > about two weeks now.

> Interesting that no one spoke up until just a week ago. =A0I have a fix
> and I ready to push it to David Miller.

Like Stephen said it had been there for a couple of days already at the
time it was reported; I happened to be busy at the time it came up so
wasn't looking at the build reports myself.  If you've got a fix please
get it submitted ASAP, having common test configurations broken for any
length of time does get disruptive.

--pqRbAPYjtlk7lrMB
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJXHU/ZAAoJECTWi3JdVIfQfewH/3uIlJ0iJUahHVBtiLkBRJZy
9bbXqvLOdaO6jyy7bRfTLm8pAWbJv8qILGZoUNHhmXfjHsEFgQqJM4Y/ckPul5OX
IbL2vcW8Ja8r6GtDvTMUE8wK43UUSKdgxDv8JLTYbJHl822WJ3uvmEQW8TCCLOvK
XYAccWam7eLYuSRASjh4vh3CSLOeq30ltwpXewW8eKJmpBR0hVGnc2MW8r9twMsd
i9GYJCbDW9X9J3JTE+ZeoVypKEoF2DgE5wfKdbu+4aHpfK5jjax8ToDblmhul5iw
L4yAiZBSdL+tc8sUQ0/jSJrAdGNl0g4g7R8fSS2XII7OJ9uDh7ZypF/vVycIM4Y=
=QF0H
-----END PGP SIGNATURE-----

--pqRbAPYjtlk7lrMB--
