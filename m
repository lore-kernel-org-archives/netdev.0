From: "Stefan (metze) Metzmacher" <metze@samba.org>
Subject: Re: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm:
 mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Fri, 03 Jun 2011 11:35:02 +0200
Message-ID: <4DE8AAC6.6020507@samba.org>
References: <1306922913-17803-1-git-send-email-metze@samba.org> <1306922913-17803-2-git-send-email-metze@samba.org> <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E583@EXDCVYMBSTM006.EQ1STM.local> <4DE618B7.5070903@samba.org> <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E64B@EXDCVYMBSTM006.EQ1STM.local> <4DE6287D.5080807@samba.org> <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E6F2@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig60248AFEEDF0374A253200F2"
Cc: Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.180]:55174 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545Ab1FCJfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 05:35:09 -0400
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E6F2@EXDCVYMBSTM006.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig60248AFEEDF0374A253200F2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 01.06.2011 14:27, schrieb Alexey ORISHKO:
>> -----Original Message-----
>> From: Stefan (metze) Metzmacher [mailto:metze@samba.org]
>> Sent: Wednesday, June 01, 2011 1:55 PM
>=20
>>> If you use udev rules and create an alias for your device, you won't
>>> be dependent on generic driver code.
>>
>> Ok, do you have examples for that?
>=20
> Please, read udev man pages. Rule might be as follows
> KERNEL=3D=3D"usb*", ATTRS{idVendor}=3D=3D"04cc", ATTRS{idProduct}=3D=3D=
"xxxx", NAME=3D"ste_bridge0"

Thanks! I got something that works.

metze


--------------enig60248AFEEDF0374A253200F2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk3oqsYACgkQm70gjA5TCD87CwCgzXWJmSZVm4/tJ6xiDfYrRJ3z
osoAn1x39yrneUMWepRISZLggnv8jQ2i
=WwP2
-----END PGP SIGNATURE-----

--------------enig60248AFEEDF0374A253200F2--
