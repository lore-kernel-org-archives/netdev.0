From: "Stefan (metze) Metzmacher" <metze@samba.org>
Subject: Re: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm:
 mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Wed, 01 Jun 2011 12:47:19 +0200
Message-ID: <4DE618B7.5070903@samba.org>
References: <1306922913-17803-1-git-send-email-metze@samba.org> <1306922913-17803-2-git-send-email-metze@samba.org> <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E583@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig49BE8D511B2AB51562A9B33A"
Cc: Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E583@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig49BE8D511B2AB51562A9B33A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 01.06.2011 12:20, schrieb Alexey ORISHKO:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Stefan Metzmacher
>> Sent: Wednesday, June 01, 2011 12:09 PM
>=20
>=20
>> -	.flags =3D FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
>> +	.flags =3D FLAG_WWAN | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
>=20
> This patch will introduce incompatibility with already existing
> applications, which track usbX devices. As a result, end user
> application will stop working.

The same argument would apply to commits
e1e499eef2200c2a7120c9ebf297d48b195cf887 and
c261344d3ce3edac781f9d3c7eabe2e96d8e8fe8,
while they made it into the upstream kernel.

So I would think that such a change should be ok for a next release,
but without backport to stable branches.

> cdc_ncm driver can also be used for local link terminated in device,
> so wwan would be inappropriate name.

Would it be possible to add some autodetection for known devices,
in a similar way the cdc_ether driver does it.

It's really strange that Ericsson F3507g and Ericsson F5521gw appear as
different kind of devices, while using the same kernel version.

And Ericsson F3507g already changed from usbX to wwanX between 2.6.32
(ubuntu 10.04)
and 2.6.38 (ubuntu 11.04).

metze


--------------enig49BE8D511B2AB51562A9B33A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk3mGLcACgkQm70gjA5TCD+X8wCfQje3Fe/dUh+L1jd1yimharWY
yRIAoMRkCc8JzoTJeXStAxoFWdgG+wZc
=jsFn
-----END PGP SIGNATURE-----

--------------enig49BE8D511B2AB51562A9B33A--
