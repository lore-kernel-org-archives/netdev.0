From: Ben Hutchings <ben@decadent.org.uk>
Subject: TX watchdog fires for ipheth after phone upgraded to iOS 5
Date: Thu, 03 Nov 2011 14:39:31 +0000
Message-ID: <1320331171.3079.31.camel@deadeye>
References: <20111103135222.3555.69704.reportbug@thib.infomaniak.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GmHXaUab6Oocgf+mG9Wz"
Cc: 647513@bugs.debian.org, netdev <netdev@vger.kernel.org>
To: Diego Giagio <diego@giagio.com>, darx <tr@omch.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41233 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753215Ab1KCOjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 10:39:55 -0400
In-Reply-To: <20111103135222.3555.69704.reportbug@thib.infomaniak.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GmHXaUab6Oocgf+mG9Wz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-11-03 at 14:52 +0100, darx wrote:
> Package: linux-2.6
> Version: 3.0.0-3
> Severity: important
> Tags: upstream
>=20
> Hi,
>=20
> After IOS5 update on my iphone when I plug it on my Debian, it crashes.

No it doesn't.

> As I'm using it as a modem it's quite problematic.
>=20
>=20
> Nov  3 14:16:51 thib kernel: [  371.824017] ------------[ cut here
> ]------------
> Nov  3 14:16:51 thib kernel: [  371.824024] WARNING: at /build/buildd-
> linux-2.6_3.0.0-3-amd64-9ClimQ/linux-2.6-3.0.0/debian/build/source_amd64_=
none/net/sched/sch_generic.c:255
> dev_watchdog+0xe9/0x148()
> Nov  3 14:16:51 thib kernel: [  371.824027] Hardware name: OptiPlex 780
> Nov  3 14:16:51 thib kernel: [  371.824029] NETDEV WATCHDOG: eth1 (ipheth=
):
> transmit queue 0 timed out
[...]

Diego, please can you investigate this.

Ben.

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.

--=-GmHXaUab6Oocgf+mG9Wz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATrKnpOe/yOyVhhEJAQokdBAAyHuJR38ce9tvUewN9znvVhtX3u6GAdFe
DDA8uSIuCjYU478eiDC1QMN2/t2wbJvZ1uWk76H9ZV+VQ+w+5zm1l5QyznkK2u+K
teojbDHasaHdlbgVubcUY43+1pUnrXD7ZsVbALnDZQ7faGax9L6rtY2vhJtxuxhx
FbESC37rJHffWM4r3h37+0GREf94fj1vIEPWlV/4nF4YXYl3NmA+//Jie3bf+AQB
p+7wNUKtLfW8Li56GCve3qPwDuy7aq0Gj1RufHzYk9TwUm9ScUFRcDUHU4xmWbB9
L6f4B1fniCl3SwecZDZC8KfqfwZDnBSFtYIfGLyQUR3mupiUbBhyMAlWzlz/mbcD
KG9lXdMKgYYY6d/VpjOYxQjuwWqn1FBQiAg0fc4m0F/9fbBS0IZnuBrBLjUJ5WQO
nuEuHMnhbuTWUXu+mXh1i2hDJuOYIF0Ibj7LHQPaQ7xpLGw8LAiUT3oFyYOtbBST
OGLtTUVwIWOJKmREn+AqhPEf7ZVPVn1ENG9P7lMYfm9t8RFEsEvYg3TfQpar8oRR
fatR2YUbeKn0oSekNp2976aKwAfeb5s7OjJD2WdH9ZWvkDSeRSBcaGHJitSG6teq
QSD9RtcDWEvxbAQAP1dj4d4dl8Cff2edkZM9u88KXhyDXnn3nNJldAQrthb5pslH
IAc/+iBQkNU=
=AiDE
-----END PGP SIGNATURE-----

--=-GmHXaUab6Oocgf+mG9Wz--
