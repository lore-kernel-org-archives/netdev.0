From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 3/6] 6lowpan: move 6lowpan.c to 6lowpan_rtnl.c
Date: Sat, 22 Feb 2014 13:40:52 +0000
Message-ID: <1393076452.15717.98.camel@deadeye.wl.decadent.org.uk>
References: <1392995711-19563-1-git-send-email-alex.aring@gmail.com>
	 <1392995711-19563-4-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WWcj7muTy17QdKxjJHb4"
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, martin.townsend@xsilon.com
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56991 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751286AbaBVNkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 08:40:55 -0500
In-Reply-To: <1392995711-19563-4-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WWcj7muTy17QdKxjJHb4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-02-21 at 16:15 +0100, Alexander Aring wrote:
> We have a 6lowpan.c file and 6lowpan.ko file. To avoid confusing we
> should move 6lowpan.c to 6lowpan.ko. Then we can support multiple source

You put the wrong filename here ^

Ben.

> files for 6lowpan module.
>=20
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> Tested-by: Martin Townsend <martin.townsend@xsilon.com>
> ---
>  net/ieee802154/{6lowpan.c =3D> 6lowpan_rtnl.c} | 0
>  net/ieee802154/Makefile                      | 1 +
>  2 files changed, 1 insertion(+)
>  rename net/ieee802154/{6lowpan.c =3D> 6lowpan_rtnl.c} (100%)
>=20
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan_rtnl.c
> similarity index 100%
> rename from net/ieee802154/6lowpan.c
> rename to net/ieee802154/6lowpan_rtnl.c
> diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
> index e8f0588..3d08adf 100644
> --- a/net/ieee802154/Makefile
> +++ b/net/ieee802154/Makefile
> @@ -2,5 +2,6 @@ obj-$(CONFIG_IEEE802154) +=3D ieee802154.o af_802154.o
>  obj-$(CONFIG_IEEE802154_6LOWPAN) +=3D 6lowpan.o
>  obj-$(CONFIG_6LOWPAN_IPHC) +=3D 6lowpan_iphc.o
> =20
> +6lowpan-y :=3D 6lowpan_rtnl.o
>  ieee802154-y :=3D netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o
>  af_802154-y :=3D af_ieee802154.o raw.o dgram.o

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-WWcj7muTy17QdKxjJHb4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwio5Oe/yOyVhhEJAQoruhAAvxV9ISEAf+EEFkxweDLmBWfEaHwENnsi
acX1LQmJBPJsRlLR00XW8sOof1Bf6VSDzpajo4GSJ/xhUYizu/FifFFE+3xG031c
SCXyBgvhNJYrl7UNogdPk2uMhFBr6uJYXnTpzS3Fy6LbfYlGV8AgIyzrk6K/OYnk
MxzHSUk1uzZKExF1c4rotemBOYeUznEj55mgfMiuZG2fh2zHJQ7v0g5NWUwgWUw4
YunRh6RcPUDH+3eJSb2st2MrmqvzkHpwfZrLwUGN42mx/WDks4hblFej47L7e1cr
hLFug/ohm7jBLXJ/WuocNXqmzNLISGkCpkIRIdOb6dkW0xkyk5CPAVu3uEaUXeDc
/qFGVRIo0U8RycfVxJ5OqXf0jWtn5g9EQ9it/Co1LoDQ3gO/M9LJhPpWB/Tr0hxO
HapRqeDR3FKNiBUUguNCTSncnjNYpiMCWMQxFAZiu9XqLbS07ZyWwf0C4xwRhkj0
IacboCqi0rC8Rn7fLIZTpneu3PwQnZdnhe70ujropUDBHkvj2WjzkDYq0Cr2rVQY
uUsPIWNJIA1GyPWNJlXn7IJJD6Biei24JrIE4g8tp89O1Dt3pWhZtiiMMENg/W0g
ywQjww/siTT9Upo9qlWXTr6ZKUNfbQH7GCbA6EdtltYBeRut+h8W30s2BUOtVDat
7BbynvUeBXM=
=eL9h
-----END PGP SIGNATURE-----

--=-WWcj7muTy17QdKxjJHb4--
