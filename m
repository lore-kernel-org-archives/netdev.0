From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 07/17] new helpers: skb_copy_datagram_from_iter() and
 zerocopy_sg_from_iter()
Date: Mon, 24 Nov 2014 00:29:40 +0000
Message-ID: <1416788980.7215.66.camel@decadent.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
	 <20141120214753.GR7996@ZenIV.linux.org.uk>
	 <20141120.182339.972861702759954603.davem@davemloft.net>
	 <20141121.122615.1091044030302005883.davem@davemloft.net>
	 <20141122042856.GZ7996@ZenIV.linux.org.uk>
	 <20141122043320.GG30478@ZenIV.linux.org.uk>
	 <1416787365.7215.63.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-O42VdvIkrQJ32zf2RE2Q"
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	hch@infradead.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416787365.7215.63.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-O42VdvIkrQJ32zf2RE2Q
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-11-24 at 00:02 +0000, Ben Hutchings wrote:
> On Sat, 2014-11-22 at 04:33 +0000, Al Viro wrote:
> [...]
> > --- a/net/core/datagram.c
> > +++ b/net/core/datagram.c
> > @@ -572,6 +572,77 @@ fault:
> >  }
> >  EXPORT_SYMBOL(skb_copy_datagram_from_iovec);
> > =20
>=20
> Missing kernel-doc.
[...]

Never mind, I can see that patches 9 and 10 recycle the _iovec
functions' kernel-doc comments.

Ben.

--=20
Ben Hutchings
Absolutum obsoletum. (If it works, it's out of date.) - Stafford Beer

--=-O42VdvIkrQJ32zf2RE2Q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHJ79ee/yOyVhhEJAQrCFg//ZODm5r8eMweaADJHu5C0vKLYfkFRrv4S
Wx4zGgMMI0IyUFIjogZOKOcINWgCZu7i+YyrGYx5FjBztJQs2MoEHyE+eNgC9fym
qV9S7sHUWIW8OkEnmbjIV9bW1mWZ8aqersjvSzTRJx/6VD6reL63aMt9aFbbFXb8
Bq4Gs9yE2zPSXPqRau2wHemi1cg2zwh5dIhLHmQmRbWuLwFPQ0hHCF3l0x1ThPjZ
qCCYz+/K//GrjtdtRr4GLviHRktkPDpRYfsGv6TQgQ9HiWQZQjRDZBlCrNgJiosD
bHH9b57JA7RMevSBOb4qvLLYCRkjWJt8rweo/yVsMpQxFY1OcfrnEitONJ/AUzbW
BP8QT8Z6+LG5pwoPjkwabRltjOfCSeQBK80LUwalQxUc41TgmOSjJs7NIlDYYU3X
pr/dHpAryij1AVJiiHwUuYGJy1x6VShTVeHLJE2T+Xt2nI7DmlTyZeBCX+k8sh68
7UfPSXIzAyCCBMfGFgXo1qB6uihosPFp8rHXGYi1TrGuESi+soAJiprqEPuv0V9e
UXXlmgmbXwrAS0Q7ssFZtRrKfKnZ5ufZl5dnaVWRAoa3Jz9Tc5iIBQpuP2COMwrg
fndRgaJ0no6JpZ9kUylT3lBGhOj6ZW04Cf3d01Mry5fz11OhYs3A7lw7bKbhUNFC
THlXOQ9OnhU=
=OXeo
-----END PGP SIGNATURE-----

--=-O42VdvIkrQJ32zf2RE2Q--
