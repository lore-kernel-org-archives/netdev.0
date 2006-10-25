From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: about 802.11i IBSS support
Date: Wed, 25 Oct 2006 23:46:20 +0200
Message-ID: <1161812780.8884.3.camel@johannes.berg>
References: <1161766481.8668.38.camel@devlinux-hong>
	 <20061025154815.GA15348@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-TBVH/+Fk53RCEAuhibpo"
Cc: Hong Liu <hong.liu@intel.com>, Jiri Benc <jbenc@suse.cz>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:157 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750931AbWJYVr7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 17:47:59 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20061025154815.GA15348@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-TBVH/+Fk53RCEAuhibpo
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-10-25 at 08:48 -0700, Jouni Malinen wrote:

> > 1. for the d80211 part: I don't think there will be much efforts.
> >    We may add a group key to each sta_info for decrypting multicast dat=
a from that STA.
> >    And in RX path, we need to add code to select the correct group key =
for decryption.
> >    And also we need to store our own group key used to send multicast d=
ata to others.
>=20
> This will also include looking into how different WLAN chipsets
> have implemented (or will implement) hardware acceleration for such a
> case.

For bcm43xx, you can use any key for TX. At RX, the mac address of the
sender is used to look up which key to use (broadly spoken). But if the
frame is multicast, bcm43xx can only use the 4 default keys if enabled.
That said, we're recently started to reverse engineer the firmware and I
can see that it should be trivial to also do a mac address matching for
multicast frames and use different keys then.

johannes

--=-TBVH/+Fk53RCEAuhibpo
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUART/bK6Vg1VMiehFYAQJZZA//TkR0viUF33YUN/ItZnbjOx4zmlsWAD4/
DBW28PgYRAwyPpNrSR0DVE/cvX5CZXOo5Rlhji/I4pXCMkxKofFkyFe0OxukhMmM
7yXZh/27e9K6Zqomofj4kI9zC+v62gRcEWv4TJf8xwJ+Y5kQ1Yj+Y3mrThJH7rJE
U9wl5ryNuO9T8Iw+lH0xu1xcLfwZqjCRa47mkQ7lbe5kSZUzU3QrYbCEcKnXdj9A
WibKzmhZjp9MpxN9gahJUy1yxj4keu+oK6c2zLLwyJZ5iCZ2ODPZvKheH6OVhCKG
FkG0KnzFs8XMVd/PzLOmZWByZ9M13p4luvSxvReljJEmEnPAnJ70YJo0cmogpQUi
HE6gbPROGeDgOU+jWuC/m7xKaE1ABNYyyjBqckAT16pljUIKi9g4Phf2/wr6fMUZ
xDQs35npHrirnBq/70DqG4d05Lv2WCfcwBzJqDr4pqZba6dWpl2ZRPk11y3bhSlP
DjyJGnrI/zmQH28knnR59rxSBe5YNSgc44Vj+sKrgtM+/guBFogR7NOVwjQjhp/X
BnM6VIFAEMFgTF5mu+AVCEqpIdZzyxJxAXi7gN/CttaMLo5GVlcj3klcGpTkt7IP
hZqSme2qgiuE1h7umnGTl1G9qx3gQ5hLKF2O8hB0j7bTAzrO3VDEVyMSjI1de7Vy
CsRoSr5CBLA=
=rLK1
-----END PGP SIGNATURE-----

--=-TBVH/+Fk53RCEAuhibpo--

