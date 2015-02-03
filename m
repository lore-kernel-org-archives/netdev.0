From: Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>
Subject: Re: [PATCH] ath9k_htc: add adaptive usb flow control to repair soft
 lockup with monitor mode
Date: Tue, 03 Feb 2015 15:35:25 +0100
Message-ID: <54D0DCAD.8060409@rempel-privat.de>
References: <1422957585-19736-1-git-send-email-yuweizheng@139.com> <87fvanxldu.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="iUpB7LPx2HInfLWVkAtsumNpumKIEm6uj"
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Yuwei Zheng <zhengyuwei-z+sInHIpZSw@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, yuweizheng-7R9yAhoRP9E@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87fvanxldu.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iUpB7LPx2HInfLWVkAtsumNpumKIEm6uj
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

It seems to work without noticeable regressions.

Am 03.02.2015 um 12:52 schrieb Kalle Valo:
> yuweizheng-7R9yAhoRP9E@public.gmane.org writes:
>=20
>> From: Yuwei Zheng <yuweizheng-7R9yAhoRP9E@public.gmane.org>
>>
>> In the environment with heavy wifi traffic, set the ar9271 into monito=
r mode, will
>> trigger a deadloop panic.
>> =20
>> The ath9k_hif_usb_rx_cb function excute on  the interrupt context, and=
 ath9k_rx_tasklet excute
>> on the soft irq context. In other words, the ath9k_hif_usb_rx_cb have =
more chance to excute than
>> ath9k_rx_tasklet.  So in the worst condition,  the rx.rxbuf receive li=
st is always full,
>> and the do {}while(true) loop will not be break. The kernel get a soft=
 lockup panic.=20
>=20
> The word wrapping is still wrong, please limit the width to 72 chars or=

> so. But no need to wrap log snippets, they can exceed the limit.
>=20
>> Signed-off-by: Yuwei Zheng <zhengyuwei-z+sInHIpZSw@public.gmane.org>
>> Signed-off-by: Yuwei Zheng <yuweizheng-7R9yAhoRP9E@public.gmane.org>
>=20
> Why two of these? Please use just one Signed-off-by line. Unless these
> are two different persons with the same name :)
>=20


--=20
Regards,
Oleksij


--iUpB7LPx2HInfLWVkAtsumNpumKIEm6uj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iF4EAREIAAYFAlTQ3LIACgkQHwImuRkmbWlnBQD/UqYjFgmRJJN5eTPDzTkqtBgh
1jOz1JyQN7UA3qOVSlwA/3fcKEeAExwgxbBjrCwv4YGxCffxeAYgPh8v1r6ICL//
=8qX6
-----END PGP SIGNATURE-----

--iUpB7LPx2HInfLWVkAtsumNpumKIEm6uj--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
