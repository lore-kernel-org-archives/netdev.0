From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: Thu, 15 Jul 2004 19:27:24 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089905244.6114.887.camel@uganda>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-hDCZSjtMqGKyhOIxok8K"
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1089902654.1029.23.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-hDCZSjtMqGKyhOIxok8K
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-07-15 at 18:44, jamal wrote:
> Evgeniy,
>=20
> Why do you need to put this stuff in the kernel?
> This should be implemented just the same way as VRRP was - in user
> space.

Hmm...
Just because i think it works better being implemented in the kernel? :)
I don't think it is a good answer thought.

It is faster, it is more flexible, it has access to kernel space...

> BTW, is there a spec for this protocol or its one of those things where
> you have to follow Yodas advice?

Exactly :)
Here are all links I found:
http://www.countersiege.com/doc/pfsync-carp/
http://www.openbsd.org/cgi-bin/man.cgi?query=3Dcarp&apropos=3D0&sektion=3D0=
&manpath=3DOpenBSD+Current&arch=3Di386&format=3Dhtml#SEE+ALSO
http://www.openbsd.org/lyrics.html
VRRP2 spec.
http://www.openbsd.org/cgi-bin/cvsweb/src/sys/netinet/ip_carp.c


I do want this to be in the mainline kernel, but actually I even don't
think anyone will apply it.
It is too special stuff for generic kernel, it has reserved 112 vrrp
protocol number and so on...
So if developers decide not to include or even not to discuss this cruft
I will not beat myself by my heels. :)

It just works as expected, it is reliable and simple.
And it does it's work, so HA people would like it.

> cheers,
> jamal
--=20
	Evgeniy Polaykov ( s0mbre )

Crash is better than data corruption. -- Art Grabowski

--=-hDCZSjtMqGKyhOIxok8K
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA9qJcIKTPhE+8wY0RAmZvAJ99AOTG7YFuRAVvbZU7c38KJZ6PEgCfXGKX
0Hw/Z6O705yPJRI+D5w9Ag0=
=AdlC
-----END PGP SIGNATURE-----

--=-hDCZSjtMqGKyhOIxok8K--
