From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Mon, 01 Nov 2004 09:01:44 +0300
Message-ID: <1099288904.5070.75.camel@uganda>
References: <1099030958.4944.148.camel@uganda>
	 <1099053738.1024.104.camel@jzny.localdomain>
	 <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
	 <20041030203550.GB6256@gate.ebshome.net>
	 <20041031010415.4c798a04@zanzibar.2ka.mipt.ru>
	 <20041030205630.GD6256@gate.ebshome.net>
	 <20041031012423.74b98698@zanzibar.2ka.mipt.ru>
	 <1099179687.1041.117.camel@jzny.localdomain>
	 <20041031121308.648e98f9@zanzibar.2ka.mipt.ru> <4184C286.3000400@suse.cz>
	 <1099235030.1038.192.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Wz3a8jLEwwUmA2AknEAN"
Cc: Michal Ludvig <mludvig@suse.cz>, netdev@oss.sgi.com,
        cryptoapi@lists.logix.cz, Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1099235030.1038.192.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Wz3a8jLEwwUmA2AknEAN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2004-10-31 at 18:03, jamal wrote:
> On Sun, 2004-10-31 at 05:46, Michal Ludvig wrote:
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA1
>=20
> > Yes, I have *some* numbers, but consider that they are for quite
> > eligible setup - encrypting ~1.5k IPsec packets. I should retry with a
> > much smaller MTU to see the difference...
> >=20
>=20
> You should try with different packet sizes for different hardware, or
> s/ware drivers with and without async; with and without batching.
> packet sizes 64,256,512,1024,1500 bytes. batch sizes, 1,2,4,8,16,..
>=20
> > I think it won't be the programmer but the system administrator who wil=
l
> > have to correctly set priorities and constraints for different
> > hardware/software engines for the particular system.=20
>=20
> Why is the admin involved in such decision making?
>=20
> > With a slow CPU it
> > may be worth to offload even small blocks to hardware, with a fast one
> > it may be worth to set HW and SW as equal, etc.
> >=20
>=20
> I think the system should discover all this at runtime.
> If the driver says its busy, you dont give it more work.
> Clearly giving it more data is beneficial; hence before it gets busy
> you give it enough to overcome the setup cost.
> You should have qos (start with simple strict priority); and the
> preference could be given to large packets etc as long as you dont
> introduce reordering.

Crypto session priority already exists - sessions are placed into=20
the queues in order of it's priority.
It is supposed that crypto device driver will get them in this order
too.

> Come to think of it, this would be really easily doable if the crypto
> device appeared to the system as a netdevice.

:) First of all it would be good to stabilize what we already have.

> cheers,
> jamal
>=20
> _______________________________________________
>=20
> Subscription: http://lists.logix.cz/mailman/listinfo/cryptoapi
> List archive: http://lists.logix.cz/pipermail/cryptoapi
--=20
	Evgeniy Polyakov

Crash is better than data corruption. -- Art Grabowski

--=-Wz3a8jLEwwUmA2AknEAN
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBhdFIIKTPhE+8wY0RAs73AKCXXaL6crR6IYMqUNAII4gl12JLWwCcD1Ve
sFf7dxbcQdxY4sbuJP11UqA=
=UshT
-----END PGP SIGNATURE-----

--=-Wz3a8jLEwwUmA2AknEAN--
