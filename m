From: Tom Marshall <tommy@home.tig-grr.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Tue, 16 Sep 2003 08:15:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916151533.GA28380@home.tig-grr.com>
References: <200309022116.41697.bdschuym@pandora.be> <20030905153152.GA3623@obroa-skai.de.gnumonks.org> <20030908191400.5ef59ab6.davem@redhat.com> <200309132159.37834.bdschuym@pandora.be> <20030915155903.12a3f95d.davem@redhat.com> <20030916140621.GE810@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>, "David S. Miller" <davem@redhat.com>,
   Bart De Schuymer <bdschuym@pandora.be>, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20030916140621.GE810@obroa-skai.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 16, 2003 at 04:06:21PM +0200, Harald Welte wrote:
> On Mon, Sep 15, 2003 at 03:59:03PM -0700, David S. Miller wrote:
>=20
> > I have to reject the fix for this problem again.
> >=20
> > You can't change the struct exported to userspace in any way
> > without breaking the tools.  I tried to explain this in the
> > first revision of your change.
>=20
> But ipt_physdev is a 2.6ism, thus we can still introduce any
> incompatibility... For me it's enough to be compatible within 2.4 or
> within 2.6.x (once 2.6.0 is out).

Noooo!  Please don't break compatibility for 2.6.  I really don't want to
have separate /sbin/iptables-2.4 and /sbin/iptables-2.6 binaries.

--=20
Logic is a systematic method of coming to the wrong conclusion with
confidence.

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iEYEARECAAYFAj9nKRUACgkQFMm9uvwPXW79sACeKTonAiYJ32Mzkw/82LQ7WXgj
dcoAn2A4I89L7diDC6n10ogEz+QsYzLq
=hQMT
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
