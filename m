From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Allowing netlink_family to be any integer (was: [PATCH 2.6]
	iptables CLUSTERIP target)
Date: Fri, 22 Oct 2004 16:32:39 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098448359.5211.199.camel@uganda>
References: <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au>
	 <1098444579.1112.66.camel@jzny.localdomain>
	 <20041022113939.GA812@gondor.apana.org.au>
	 <1098447593.1112.77.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-HXl5JTrDdsdSWwPTLq5P"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Harald Welte <laforge@netfilter.org>, lmb@suse.de, ahu@ds9a.nl,
        hch@infradead.org, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1098447593.1112.77.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-HXl5JTrDdsdSWwPTLq5P
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2004-10-22 at 16:19, jamal wrote:
> On Fri, 2004-10-22 at 07:39, Herbert Xu wrote:
> > On Fri, Oct 22, 2004 at 07:29:39AM -0400, jamal wrote:
> > >=20
> > > Evgeniy Polyakov(aka mr. Sean Paul) posted code a while back for
> > > something that uses netlink that he calls  "kernel Konnector". I thin=
k
> >=20
> > That patch puts the ID in each message, right?
>=20
> Yes, the ID is necessary for "routing" the message. Remember this is for
> a messaging subsystem so you cant avoid having something that is in the
> packet that is used to find where to go next.
> I was suggesting also messaging by name.
>=20
> > That would mean paying the lookup cost for each message rather than
> > once when you create the socket.
> >=20
>=20
> Take a look at the patch. See how it can be made better.
> Evgeniy, Do you have something new to post?

Nothing major, only multicast group selection by id.
Although I think message sending mechanism can use unicast.
Both have it's own advantages.

> cheers,
> jamal
--=20
	Evgeniy Polyakov

Crash is better than data corruption. -- Art Grabowski

--=-HXl5JTrDdsdSWwPTLq5P
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBeP3nIKTPhE+8wY0RArXvAJ4gsjSz2qu8IfAeF+yxFVKhSD00MACdFw5Z
wFcp/DrOqTxn+26ZYjEmESA=
=AHJB
-----END PGP SIGNATURE-----

--=-HXl5JTrDdsdSWwPTLq5P--
