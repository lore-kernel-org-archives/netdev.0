From: "Stefan (metze) Metzmacher" <metze@samba.org>
Subject: Re: [PATCH] usbnet/cdc_ncm: add missing .reset_resume hook
Date: Mon, 06 Jun 2011 14:23:16 +0200
Message-ID: <4DECC6B4.5020108@samba.org>
References: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E568@EXDCVYMBSTM006.EQ1STM.local>	<1306929701-22861-1-git-send-email-metze@samba.org>	<1306929701-22861-2-git-send-email-metze@samba.org> <20110601.211142.557328157396419857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9604938BF97759CABEE2856C"
Cc: oliver@neukum.name, gregkh@suse.de, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:44308 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754357Ab1FFMX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 08:23:28 -0400
In-Reply-To: <20110601.211142.557328157396419857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9604938BF97759CABEE2856C
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi David,

> From: Stefan Metzmacher <metze@samba.org>
> Date: Wed,  1 Jun 2011 14:01:41 +0200
>=20
>> This avoids messages like this after suspend:
>>
>>    cdc_ncm 2-1.4:1.6: no reset_resume for driver cdc_ncm?
>>    cdc_ncm 2-1.4:1.7: no reset_resume for driver cdc_ncm?
>>    cdc_ncm 2-1.4:1.6: usb0: unregister 'cdc_ncm' usb-0000:00:1d.0-1.4,=
 CDC NCM
>>
>> This is important for the Ericsson F5521gw GSM/UMTS modem.
>> Otherwise modemmanager looses the fact that the cdc_ncm and cdc_acm de=
vices
>> belong together.
>>
>> The cdc_ether module does the same.
>>
>> Signed-off-by: Stefan Metzmacher <metze@samba.org>
>=20
> Applied and queued up for -stable, thanks.

It seems to be part of 3.0-rc2, but I'm not seeing it in any stable tree
yet...

When can I expect it in stable trees like 2.6.38.y?

metze


--------------enig9604938BF97759CABEE2856C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk3sxrcACgkQm70gjA5TCD8utQCgjasCJ5x8pTFcoc900VckFHQj
LQQAn2hIj/Ip/PK89y7lT4Fh26mb5WTw
=oKTy
-----END PGP SIGNATURE-----

--------------enig9604938BF97759CABEE2856C--
