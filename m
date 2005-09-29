From: Harald Welte <laforge@gnumonks.org>
Subject: Re: rwlock recursion on CPU#0, netfilter related?
Date: Thu, 29 Sep 2005 14:05:38 +0200
Message-ID: <20050929120538.GT4168@sunbeam.de.gnumonks.org>
References: <20050925105834.GA15243@ee.oulu.fi> <20050925134344.GJ731@sunbeam.de.gnumonks.org> <20050925201945.GA21176@ee.oulu.fi> <20050928145815.GA421@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NEaRsfQExFH3jWtg"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
Content-Disposition: inline
In-Reply-To: <20050928145815.GA421@ee.oulu.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--NEaRsfQExFH3jWtg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 28, 2005 at 05:58:15PM +0300, Pekka Pietikainen wrote:
> On Sun, Sep 25, 2005 at 11:19:45PM +0300, Pekka Pietikainen wrote:
> > Enabled, so this could be it. But 2.6.14-rc2-git4 did crash too (althou=
gh
> > it did take a bit longer for that to happen), and the changelog does st=
ate:
> Ok, it looks like that patch was the thing after all. I now tried the lat=
est
> fedora-devel kernel (1.1582, based on 2.6.14-rc2-git6) and the box has be=
en
> running for a few hours happily. Could be the fedora kernel that claimed =
to
> be git4 actually wasn't, or the git4 changelog was really a post-git4
> changelog :). But anyway, bug is gone.

great news.

> This one is still around, so it's a different bug. Looks like it's a 64-b=
it
> issue, a 32-bit ping gives realistic ping times. tcpdump timestamps are a=
lso
> affected, they're completely off too. So looks like someone broke packet
> timestamps on 64-bit some time after 2.6.13.

luckily I'm not the core network maintainer ;)

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--NEaRsfQExFH3jWtg
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDO9iSXaXGVTD0i/8RApLKAJ9/16WAsgolDwJ3+niYa/fTSc5tHwCfUozU
G3CSD+pENTT+gp8tvfY1+2g=
=CtHq
-----END PGP SIGNATURE-----

--NEaRsfQExFH3jWtg--
