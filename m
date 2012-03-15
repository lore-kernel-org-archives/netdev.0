From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#664064: linux-image-3.3.0-rc6-amd64: 4 messages every
 minute in syslog from netlink
Date: Thu, 15 Mar 2012 17:14:13 +0000
Message-ID: <1331831653.3022.228.camel@deadeye>
References: <20120315120008.14655.64028.reportbug@apollon>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KIyaNR5J/qTWa00dNP4S"
Cc: netdev <netdev@vger.kernel.org>
To: Reinhard Karcher <reinhard.karcher@gmx.net>, 664064@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33442 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031127Ab2COROX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 13:14:23 -0400
In-Reply-To: <20120315120008.14655.64028.reportbug@apollon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KIyaNR5J/qTWa00dNP4S
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-03-15 at 13:00 +0100, Reinhard Karcher wrote:
> Package: linux-2.6
> Version: 3.3~rc6-1~experimental.1
> Severity: normal
>=20
> The kernel log says all!
> I have 2 laptops showing the messages, both amd64.
> One of them runs a 32-bit system in a VM with the linux-image-3.3.0-rc6-6=
86-pae kernel,
> that does not have this problem.
> The amd64 kernel from unstable (3.2.0-2) does not show the messages.=20
>=20
> Reinhard
>=20
> -- Package-specific info:
> ** Version:
> Linux version 3.3.0-rc6-amd64 (Debian 3.3~rc6-1~experimental.1) (debian-k=
ernel@lists.debian.org) (gcc version 4.6.3 (Debian 4.6.3-1) ) #1 SMP Mon Ma=
r 5 20:53:11 UTC 2012
>=20
> ** Command line:
> BOOT_IMAGE=3D/boot/vmlinuz-3.3.0-rc6-amd64 root=3DUUID=3D9bb56ba6-3117-47=
d6-b07c-2cca477643e9 ro quiet cgroup_enable=3Dmemory
>=20
> ** Not tainted
>=20
> ** Kernel log:
> [46368.760279] netlink: 140 bytes leftover after parsing attributes.
[...]

The code that generates this warning (nla_parse()) has not changed
between 3.2 and 3.3-rc6, so this is probably due to a difference
elsewhere.  It seems to indicate a bug in the userland program sending
the message that is being parsed, but perhaps I misunderstand.

It would be useful if we could tell which program is sending the
message, but I think that may be difficult to do.

Ben.

--=20
Ben Hutchings
Life would be so much easier if we could look at the source code.

--=-KIyaNR5J/qTWa00dNP4S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT2IjZee/yOyVhhEJAQolTxAAxrcpTxN28fPy7y6cXZPmgkPX+7ogn0iE
B1PUNaTY8UPzMsQe6Sw5zcCtB9WqHFR/mQ9HbwU84DLz9rHyDtIRqDVVExblonz7
U1dUenzpjpeKtS3TtsJFbzkPtbli8uN7avqGcpTsjNQaPyOe9p1hjgtecpAX/WTB
S6xKIi6eMfyuD715jMae1DVwvsXWzxkTyuvD1JsPO/TH3IA4sjLZ/bNypz8cPuw8
GVNzneLZTUcAHxYdf3jussq1bk5DbGmGDDTjQHjv/+bTnw3o92TKVyLvYuWnahI4
WgsngASFZkVszC039mWvPQ5tpk7u5xLzeN26MTWvoQ3WeStD0gvt6PS7yfjbZAyj
2ThV8xfR9ZwQY/7R40ZvlXvj9r8rNgwlHwfgJXJKc+ZIAjT2R+Ci5BN1bqWhhdN6
Uykl0WgGxO2eHvnJ/Din7jydOUjCnawRbn6IfmePXIC3EeoeOF8awlYPMaH0mqtK
Fh8bidZN4UM0b1o3nvpSklfqZdOIpEvhoAdmPNVmFM9Q60rVrK73/3nrCe9xgdVD
sDQC6wT+vjR0vzR/hNgfbD/UAf3Qq0HzkPBeNwpoFNFku8BR/OKRanWRoLzLM2BE
SYvd6mOqPlcfcxRAHGetDuoDwQdvRG8pneRMMkuRb/AvKGmqt+C2s8/pYvMm0PCv
IUuerngzty0=
=DO2J
-----END PGP SIGNATURE-----

--=-KIyaNR5J/qTWa00dNP4S--
