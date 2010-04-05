From: =?UTF-8?B?IkwuIEFsYmVydG8gR2ltw6luZXoi?= <agimenez-lqZFv/KUvpAxAGwisGp4zA@public.gmane.org>
Subject: Re: [PATCHv3] drivers/net/usb: Add new driver ipheth
Date: Mon, 05 Apr 2010 20:51:23 +0200
Message-ID: <4BBA312B.2030100@sysvalve.es>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es> <201003312233.26130.oliver@neukum.org> <4BB63619.6070607@sysvalve.es> <201004040924.43949.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org, steve.glendinning-sdUf+H5yV5I@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, dgiagio-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	dborca-/E1597aS9LQAvxtiuMwx3w@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201004040924.43949.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/04/2010 09:24 AM, Oliver Neukum wrote:
> Am Freitag, 2. April 2010 20:23:21 schrieb L. Alberto Gim=C3=A9nez:
>> On 03/31/2010 10:33 PM, Oliver Neukum wrote:
>>> Am Mittwoch, 31. M=C3=A4rz 2010 21:42:07 schrieb L. Alberto Gim=C3=A9=
nez:
>>>> +static struct usb_driver ipheth_driver =3D {
>>>> +	.name =3D		"ipheth",
>>>> +	.probe =3D	ipheth_probe,
>>>> +	.disconnect =3D	ipheth_disconnect,
>>>> +	.id_table =3D	ipheth_table,
>>>> +	.supports_autosuspend =3D 0,
>>> redundant
>> Why?
>=20
> 0 is the default.

Heh, I thought that you meant that the whole struct was redundant, and
that puzzled me a little bit. Now everything is clear (my fault for not
realizing the redundant initialization to 0).

Regards,
--=20
L. Alberto Gim=C3=A9nez
JabberID agimenez-eu7EghD4TOHJ13y34KW5H97lo5+wdyHW@public.gmane.org
GnuPG key ID 0x3BAABDE1
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
