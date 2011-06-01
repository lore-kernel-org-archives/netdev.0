From: "Stefan (metze) Metzmacher" <metze-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH] usbnet/cdc_ncm: add missing .reset_resume hook
Date: Wed, 01 Jun 2011 12:03:42 +0200
Message-ID: <4DE60E7E.3080300@samba.org>
References: <1306919630-13426-1-git-send-email-metze@samba.org> <1306919630-13426-2-git-send-email-metze@samba.org> <201106011143.46667.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9144ACF09BF9ABBADC4AFBDB"
Cc: Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201106011143.46667.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9144ACF09BF9ABBADC4AFBDB
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Am 01.06.2011 11:43, schrieb Oliver Neukum:
> Am Mittwoch, 1. Juni 2011, 11:13:50 schrieb Stefan Metzmacher:
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
>=20
> Yes, it does. Have you tested this with active connections and unconnec=
ted?

Yes, I've just tested suspend while having an active connection
(My original tests where without an active connection).

BTW: I'm testing this on top of linux-image-2.6.38-8-generic from ubuntu
11.04.

metze


--------------enig9144ACF09BF9ABBADC4AFBDB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk3mDn4ACgkQm70gjA5TCD+O2ACgrrfty515dHzeOgXg4qcYQpdV
WeYAoMaBKMmob/5Bxe22z2pHW/1wJb/9
=GeEt
-----END PGP SIGNATURE-----

--------------enig9144ACF09BF9ABBADC4AFBDB--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
