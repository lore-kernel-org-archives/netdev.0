From: Harald Welte <laforge@netfilter.org>
Subject: Re: [HELP] netfilter Kconfig dependency nightmare
Date: Sat, 17 Sep 2005 17:29:31 +0200
Message-ID: <20050917152931.GA8413@sunbeam.de.gnumonks.org>
References: <20050916021451.3012196c.akpm@osdl.org>
	<20050916191959.GN8413@sunbeam.de.gnumonks.org>
	<39e6f6c705091617514457eded@mail.gmail.com>
	<20050917012315.GA29841@mandriva.com>
	<20050917080714.GV8413@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.61.0509171306290.3743@scrub.home>
	<20050917112949.GZ8413@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.61.0509171407460.3743@scrub.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kxn/JluRpPoM1h3S"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Roman Zippel <zippel@linux-m68k.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0509171407460.3743@scrub.home>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--kxn/JluRpPoM1h3S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 17, 2005 at 02:18:28PM +0200, Roman Zippel wrote:
> Since IP_NF_CONNTRACK_NETLINK is the one creating the dependency,=20
> something like this should work:

yes, I agree.  Looking at the behaviour of "menuconfig", I think your
suggestion solves the problem.  I didn't try to compile all the
combinations, though.

I'll submit a patch via DaveM soon.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--kxn/JluRpPoM1h3S
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDLDZbXaXGVTD0i/8RAmpgAKCOSIau5tzkHy5MkKL9vPKiEDk/0QCgjTSo
K7vRP5yzzrkKGrXjIGBcUWs=
=rw/1
-----END PGP SIGNATURE-----

--kxn/JluRpPoM1h3S--
