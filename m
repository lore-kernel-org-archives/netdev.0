From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netlink Connector / CBUS
Date: Tue, 05 Apr 2005 11:08:04 +0400
Message-ID: <1112684884.28858.10.camel@uganda>
References: <Xine.LNX.4.44.0504050108260.9383-100000@thoron.boston.redhat.com>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Q31YfxoFqrjCdpDRIKy3"
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, rml@novell.com,
        Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0504050108260.9383-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Q31YfxoFqrjCdpDRIKy3
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2005-04-05 at 01:10 -0400, James Morris wrote:
> On Tue, 5 Apr 2005, James Morris wrote:
>=20
> > A few questions:
>=20
> Also, please allow cn_add_callback() allow it to be passed a NULL=20
> callback function, so the caller doesn't pass in a dummy function and you=
r=20
> code doesn't waste time dealing with something which isn't real.

Why can anyone want to add callback that will not supposed to be
usefull?
Callback is called when someone sends netlink message with appropriate
idx/val inside, if there is no registered callback with such ID,=20
nothing will be called and skb will be freed.

>=20
> - James
--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-Q31YfxoFqrjCdpDRIKy3
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCUjlUIKTPhE+8wY0RAv/qAJ4gmxfOafjdLprCQ4Ue0e7d6SxbrACfcJM7
qFXZGBk8rY3rtFUCIyZgu3Q=
=0Car
-----END PGP SIGNATURE-----

--=-Q31YfxoFqrjCdpDRIKy3--
