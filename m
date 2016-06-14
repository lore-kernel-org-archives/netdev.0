From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v3 5/7] vmxnet3: add support for get_coalesce,
 set_coalesce ethtool operations
Date: Tue, 14 Jun 2016 16:04:12 +0100
Message-ID: <1465916652.3529.242.camel@decadent.org.uk>
References: <1465869007-10822-1-git-send-email-skhare@vmware.com>
	 <1465869007-10822-6-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9UEwLe/lORDS/Gt3ltbB"
Cc: Keyong Sun <sunk@vmware.com>, Manoj Tammali <tammalim@vmware.com>
To: Shrikrishna Khare <skhare@vmware.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pv-drivers@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50962 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751247AbcFNPET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 11:04:19 -0400
In-Reply-To: <1465869007-10822-6-git-send-email-skhare@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9UEwLe/lORDS/Gt3ltbB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-06-13 at 18:50 -0700, Shrikrishna Khare wrote:
[...]
> --- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
> +++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> @@ -725,6 +725,164 @@ vmxnet3_set_rss(struct net_device *netdev, const u3=
2 *p, const u8 *key,
> =C2=A0}
> =C2=A0#endif
> =C2=A0
> +static int
> +vmxnet3_get_coalesce(struct net_device *netdev, struct ethtool_coalesce =
*ec)
> +{
> +	struct vmxnet3_adapter *adapter =3D netdev_priv(netdev);
> +
> +	if (!VMXNET3_VERSION_GE_3(adapter))
> +		return -EOPNOTSUPP;
> +
> +	memset(ec, 0, sizeof(struct ethtool_coalesce));
[...]

The ethtool core already clears the structure, and it sets the cmd
field properly. =C2=A0This memset() should be removed.

Otherwise I think this is fine.

Ben.
=C2=A0
--=20
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- A=
lbert
Camus

--=-9UEwLe/lORDS/Gt3ltbB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXYBzsAAoJEOe/yOyVhhEJEKkP/A49tzqscPWRLXsCorVLcDoU
grbnTSkrw+4u2x0PFeqzpBLiqENnbiW4LR2WzRrLO+U7Dd3tErhrBD5Sv2xTV+H9
uQ5Yw1EQpQbvFi9pSebgKsTUzSdCBmgoxjcOWBfPNewtJ9pSl27sGhkmFCp5NWLc
PSKm7hFIFQxKEKpsdsEC7UsF64mzL91MGqQyWFlnon1d5KcEpNvrKHvsO2tYD9qX
+mEzAuP8orUIey+UDsxtpGhsdpSpY7WHGuyZck71Uxn5zO5vTnymUoxv+Yo76KfG
5Gsn0n/52oVXzY7pGoSZJgpiWaU08oawQwA7HXXFjiMsQiHNTyLUQy30/go99P0F
+y5bP74v0hWO5ShQ6QyhhTvMPtGqIf+gF/xvcyR7gHddBGAKTAgTgcX2ZhLVVZAR
pv++1nHPEq7kQiowEV5k3TaUIUXBucwGrysLJW+N7IkiUsAnfncsyAr5SzX+oU5b
pJ0S0yD0tf+uam2NYkFutYDYytlLIApxAq8FsHr5vn2agW7Tn45RAEOZWlxaDfce
hIxG4Y4Jb2ZWxddkTiDTW36PNrDquxUg5fANOqLY6klIl5V4TpvzXkQvOvGQOW8I
0EBdhvJoN6sSmnxXdMeGRPr0kkIbIQKZ5jV1N/YtI0/V5wH6CIqZdxUvztpF/YCj
W4ol+ORbTs205xl7o4Qx
=kIWK
-----END PGP SIGNATURE-----

--=-9UEwLe/lORDS/Gt3ltbB--
