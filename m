From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 05/11] isdn/gigaset: improve CAPI message debugging
Date: Tue, 06 Jul 2010 10:14:53 +0200
Message-ID: <4C32E5FD.70103@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>	<20100705-patch-gigaset-05.tilman@imap.cc> <20100705.192356.52184135.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCFFA499ADCAAF2B298AB9033"
Cc: isdn@linux-pingi.de, hjlipp@web.de, keil@b1-systems.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705.192356.52184135.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCFFA499ADCAAF2B298AB9033
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 2010-07-06 04:23 schrieb David Miller:
> From: Tilman Schmidt <tilman@imap.cc>
> Date: Tue,  6 Jul 2010 02:18:59 +0200 (CEST)
>=20
>> @@ -384,7 +388,7 @@ void gigaset_skb_sent(struct bc_state *bcs, struct=
 sk_buff *dskb)
>> =20
>>  	/* don't send further B3 messages if disconnected */
>>  	if (bcs->apconnstate < APCONN_ACTIVE) {
>> -		gig_dbg(DEBUG_LLDATA, "disconnected, discarding ack");
>> +		gig_dbg(DEBUG_MCMD, "disconnected, discarding ack");
>>  		return;
>>  	}
>=20
> This is against something other than net-next-2.6 even with your
> other two ISDN patches applied, because all of these lines read
> "if (ap->connected ..."
>=20
> Please tell me what exactly these patches are against so that I
> can apply them to net-next-2.6 cleanly.

They are against mainline and apply cleanly to v2.6.35-rc3.
IOW, they go on top of the series you applied to net-2.6 on
Fri, 25 Jun 2010 21:31:28 -0700 (PDT).

Specifically, the last patch of that series,
> Subject: [PATCH 5/5] isdn/gigaset: correct CAPI connection state storag=
e
makes the switch from ap->connected to bcs->apconnstate.

So if you'll postpone applying last night's series until
after your next merge of net-2.6 into net-next-2.6, it
should then apply cleanly.

Thanks,
Tilman


--------------enigCFFA499ADCAAF2B298AB9033
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkwy5gYACgkQQ3+did9BuFvSzwCeKrrYAY9AozdeQcq8clfI3bXR
lO0AniyzmzNQNVyYGUA/sXt5gJyX6NRv
=RwjI
-----END PGP SIGNATURE-----

--------------enigCFFA499ADCAAF2B298AB9033--
