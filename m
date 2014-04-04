From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: Can I make USB IP addresses persist across unplug-replug events.
Date: Fri, 04 Apr 2014 16:08:04 +0200
Message-ID: <533EBCC4.9070701@meshcoding.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6EFE84@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="XFxMmn57HTg3bkBjexXoPURbLvGsgphlM"
Cc: netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:6091 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139AbaDDOIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 10:08:32 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6EFE84@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XFxMmn57HTg3bkBjexXoPURbLvGsgphlM
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/04/14 15:47, David Laight wrote:
> Is there a sane way to stop the local IP address (etc) associated
> with a USB network interface being deleted when the USB card
> is unplugged - so that everything will recover quickly when it is
> plugged back in?
>=20
> Maybe something horrid like master-slave bonding/teaming with a dummy
> software interface which will silently discard tx traffic when the
> usb interface is missing.

What about a bridge interface? When the usb network device is plugged-in
you can enslave it in the bridge (and viceversa on unplug).

The IP is configured on the bridge so it will survive and also the users
applications using it.

no? or am I missing something important? :)


Cheers,


--=20
Antonio Quartulli


--XFxMmn57HTg3bkBjexXoPURbLvGsgphlM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJTPrzIAAoJEEKTMo6mOh1VfP0P/1tVlCe4kAN1f3k0Z1ADARSf
7tFtA32GU81ccEuQ6Y+gw8eRi+sdwMEXyJK/8QBfhF42Zvgi1GOCubO6GacYBMu6
9xa5+hARFaZ0X4Q+KvRKYyo95Aw8SMyFd5+4FuOdUCyjN5wcrZ7pD5BC323nbn77
CHaodpRXg0xdW4cfMWvT+eZGwfFU46PUezlRM1Umh+neGmMXX2V6u334v1gdf2fF
otXRDNEprMmgH2gxhQuUj2CpX6bMewmMb9/jX5k5QkP68T+CJzRafoiPy2vIyxgS
h2nF2wstjD/xiC0G9182xxlvLdGZeB4GR/RJX2xk0BTeRFH/UX1JG/vFVmzeM+gU
myCiM25omv7mvKz2/2E5AltoR/7/wIYxdytV98eQN9Gdog9D0tOzsXZ704+xPjZe
mvpQtV9dxy925ZKRFI7CxHP2v3tpiEEZOe90BaTQPG7j17U4n9K6/fu83w42CW2f
bcGKX8vnQPW3+PWOhc+glk07Y+JxXOXlJOGKOLiEC4tl6lvHdL/DkDX+6skWGhJ3
GpY+ZZ+yIKsOZQJmfoDtzchCjEPj6W/ltUJZA9gWvnYoPDz1KcD5w1KAwzWdhgI5
kV4DYILmIvlpayfw09bBkNguOr5MjdLJW9NRhtZtutWSihTyEsanehUxX7GIQGI9
W7/m838RFT0PnlDCnpMB
=JUHF
-----END PGP SIGNATURE-----

--XFxMmn57HTg3bkBjexXoPURbLvGsgphlM--
