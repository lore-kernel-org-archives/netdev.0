From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Tue, 14 Dec 2004 11:07:18 +0300
Message-ID: <1103011638.3430.33.camel@uganda>
References: <Xine.LNX.4.44.0412140159470.30724-100000@thoron.boston.redhat.com>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-TJkbJY6fW7l4d8nLjy6X"
Cc: jamal <hadi@cyberus.ca>, Michal Ludvig <michal@logix.cz>,
        netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0412140159470.30724-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-TJkbJY6fW7l4d8nLjy6X
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2004-12-14 at 02:23 -0500, James Morris wrote:
> On Tue, 2 Nov 2004, Evgeniy Polyakov wrote:
>=20
> Some feedback:
>=20
> +#define session_completed(s)   (s->ci.flags & SESSION_COMPLETED)
> +#define complete_session(s)    do {s->ci.flags |=3D SESSION_COMPLETED;} =
while(0)
> +#define uncomplete_session(s)  do {s->ci.flags &=3D ~SESSION_COMPLETED;}=
 while (0)
> etc.
>=20
> Please use static inlines for all of these things.
> Are these supposed to be exported to userspace?  Why?

No, they are not supposed to be exported, I will convert them.

>=20
> +struct crypto_conn_data
> +{
> +       char                    name[SCACHE_NAMELEN];
> +       __u16                   cmd;
>=20
> Again, exporting to userspace?

Yes, it is part of the acrypto control over connector(netlink) protocol.

>=20
> +       list_for_each_entry_safe(__dev, n, &cdev_list, cdev_entry)
> +       {
> +               if (compare_device(__dev, dev))
> +               {
>=20
> Incorrect coding style (and many more).

Sigh... :)
<very sadly> I know, know, and will change it. </very sadly>

> As mentioned before, pluggable load balacers are not needed now, and=20
> complicate the code.

I am still not giving up :) -=20
we have several TCP congestion models, we have different IO schedulers,=20
we can tune routing code(although we can not change hash to tree in
runtime).

>=20
> - James
--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-TJkbJY6fW7l4d8nLjy6X
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBvp82IKTPhE+8wY0RAgsZAJ9pWJaeUDvKpgrfXDVHdf2UNRT8ngCdHwfN
Jdzl57cr4awrEjvPcGJrO7Q=
=y8zH
-----END PGP SIGNATURE-----

--=-TJkbJY6fW7l4d8nLjy6X--
