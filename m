From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [PATCH/RFC] Reduce call chain length in netfilter (was: Re:
	do_IRQ: stack overflow: 872..)
Date: Sun, 23 Jan 2005 17:08:29 +0100
Message-ID: <1106496509.1085.1.camel@tux.rsn.bth.se>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	 <p73zn0ccaee.fsf@verdi.suse.de>
	 <1105117559.11753.34.camel@baythorne.infradead.org>
	 <20050107100017.454ddadc@dxpl.pdx.osdl.net>
	 <1105133241.3375.16.camel@localhost.localdomain>
	 <20050118135735.4b77d38d.davem@davemloft.net>
	 <1106433059.4486.11.camel@localhost.localdomain>
	 <1106436153.20995.42.camel@tux.rsn.bth.se>
	 <1106484019.3376.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-fuimzzHstOWacJ6oQqa5"
Cc: "David S. Miller" <davem@davemloft.net>, shemminger@osdl.org,
        dwmw2@infradead.org, ak@suse.de, snort2004@mail.ru, bridge@osdl.org,
        netdev@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <1106484019.3376.5.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-fuimzzHstOWacJ6oQqa5
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2005-01-23 at 13:40 +0100, Bart De Schuymer wrote:

> Hi Martin,

Hi Bart

> > I guess you never testcompiled with CONFIG_NETFILTER_DEBUG set :)
>=20
> Oops, no. I was imagining I could code that without error...
> There was another compile error with CONFIG_NETFILTER_DEBUG in the patch
> (skb that should have been (*pskb)) :(

:)

> > > +			if (verdict > NF_MAX_VERDICT) {
> > > +				NFDEBUG("Evil return from %p(%u).\n",
> > > +				        elem->hook, hook);
> > > +				continue;
> > > +			}
> >=20
> > Maybe add unlikely() around the test?
>=20
> OK. I added another one around another debugging if-statement.

I'm now running a kernel with this patch and everything seems to still
be working.
So unless someone else has something to comment I think this should be
applied.
The decrease in call-depth is important.

--=20
/Martin

--=-fuimzzHstOWacJ6oQqa5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBB88v8Wm2vlfa207ERAr8iAKCnEC6wtsFBsBXnNqjMy9u9gt/TjQCeM2BL
qaJeTtbB5wOKFi7J9BfBX4E=
=3U0/
-----END PGP SIGNATURE-----

--=-fuimzzHstOWacJ6oQqa5--
