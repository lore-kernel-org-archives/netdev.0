From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 3/3] dm9601: add support ethtool style utility
Date: Thu, 10 Mar 2016 13:17:45 +0000
Message-ID: <1457615865.3001.36.camel@decadent.org.uk>
References: <201603101253.u2ACrnUJ002444@mail.davicom.com.tw>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-CcgfkN0aVi7K8jbd6cry"
To: Joseph Chang <joseph_chang-Ubu6M+hUeUGoECsaD+WFmw@public.gmane.org>,
	'Joseph CHANG' <josright123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	'Peter Korsgaard' <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201603101253.u2ACrnUJ002444-LuMwerrUz4dPN/9CU4g/Nk1QfAb4XDUr@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-CcgfkN0aVi7K8jbd6cry
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-03-10 at 20:51 +0800, Joseph Chang wrote:
> I did verify to dump EEPROM data and also write EEPROM by per byte.
>=20
> 1.Plug dm9601/dm9621 adapter and has get dm9601.ko be 'insmod' to have 'e=
ht0',
> 2.Run ethtool v3.7 (as attached executable file and it's help display.)
> 3. Commands:
> =C2=A0=C2=A0=C2=A0./ethtool -e eth0=C2=A0=C2=A0(dump EEPROM data for all =
the .get_eeprom_len )
> =C2=A0=C2=A0=C2=A0./ethtool -E eth0 magic 0x9620 offset 0 value 0xf1=C2=
=A0=C2=A0(write 0xf1 to eeprom byte0)
> =C2=A0=C2=A0=C2=A0./ethtool -E eth0 magic 0x9620 offset 1 value 0xf2=C2=
=A0=C2=A0(write 0xf2 to eeprom byte1)
> =C2=A0=C2=A0=C2=A0./ethtool -E eth0 magic 0x9620 offset 2 value 0xf3=C2=
=A0=C2=A0(write 0xf3 to eeprom byte2)
[...]

So you only tested writing 1 byte at a time. =C2=A0Try again with 3 bytes
and you'll see how it goes wrong.

Ben.

--=20
Ben Hutchings
To err is human; to really foul things up requires a computer.
--=-CcgfkN0aVi7K8jbd6cry
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW4XP5AAoJEOe/yOyVhhEJ+YsQAI1IwOL2aHCJj2RQ9bXUQLqB
td9vbvO0nZr9X0HmE0ZLMiPXxa0WEB6wltOmaoB7Wv/pwDUrFmq1duVGj/5AHqlf
BeJE2EWtnLYLj3QgYXLwK7w49drAhY9UUUYzgfEJW0Hcj2gaYq8keNzyGACKKEqQ
+j4RTvYxiC6xv/6BnQRLEvdRCEDe4ws20Tiu7qqMmc9WG+/5HRWm8oE7bjKTEQYv
FIA3lqPhp8F1tH7lS6V8fAZGDctzkTnfSJPYWTsxlmygZ0rEfVql3WwcTuXvoeTN
FjWkonQatZYl3wTUWKkDJh49cBG8hMohTIKtEgezVTv+v/xQbTeYFNfDm/SuKPtm
m24zaKUlWJiCaOTvE83X2dDRiQMGcAyyo0MHnjqLGWWQ/gfncVvE+sK6tMNeu4e6
LSNbIa7Snbg5zf7BYu8eyk3xg+4oGogtDv/0pFj5mXfE5PCWWDoqZ2ZO4A+lk3OO
uFEQzF4V4wWQaKVEjBCW7q1xPCLFg8eVHm5jRTr6wpQXhaxdXv67vp3ds+bKiYQm
6pp6P5h+R6jA70256GUm3TldjMgzbONAR0g0UFxqrjzkSlC2t52a3lN9AWsgmQgX
E2R+nYsBGe5Qlutt5sMVJfSVdeZCLWUilKqQtIX4iO7njVSV2t+MnkDTat+vcScB
CWp7Q/mn4q8cpeGaQshL
=tNC/
-----END PGP SIGNATURE-----

--=-CcgfkN0aVi7K8jbd6cry--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
