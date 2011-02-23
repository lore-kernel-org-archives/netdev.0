From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Subject: Re: Bug#614622: linux-image-2.6.37-1-686: atl2 NIC claims NO CARRIER
 after suspend/resume; rmmod+insmod fixes the problem
Date: Tue, 22 Feb 2011 21:06:44 -0500
Message-ID: <4D646BB4.3020302@fifthhorseman.net>
References: <20110222180821.5217.2375.reportbug@localhost.localdomain> <1298423651.2211.496.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig755A19186E46EFA990EBAEC6"
Cc: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>, 614622@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from che.mayfirst.org ([209.234.253.108]:45477 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789Ab1BWCGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 21:06:52 -0500
In-Reply-To: <1298423651.2211.496.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig755A19186E46EFA990EBAEC6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/22/2011 08:14 PM, Ben Hutchings wrote:
> This bug report was made against Debian's package of Linux 2.6.37:
 [...]
> I don't see any changes to this driver between 2.6.37-rc4 (the first
> version we built as '2.6.37-trunk-686') and 2.6.37, so I think Daniel
> just had good luck with the earlier versions.

I was running 2.6.37-1~experimental.1, fwiw, since 2011-01-09.  I don't
think that was based off of rc4, because i was running
2.6.37~rc5-1~experimental.3 before that since 2010-12-16.

so the dates are:

 2010-12-16: start running 2.6.37~rc5-1~experimental.3
 2011-01-09: start running 2.6.37-1~experimental.1
 2011-02-17: start running 2.6.37-1

I run this machine every day, connect it to multiple wired networks, and
have a usage pattern of suspend-to-ram at least twice a day.  I never
saw this problem until i was running 2.6.37-1.

I don't think i was simply lucky with the previous versions.

	--dkg


--------------enig755A19186E46EFA990EBAEC6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQJ8BAEBCgBmBQJNZGu0XxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXQwRUU1QkU5NzkyODJEODBCOUY3NTQwRjFD
Q0QyRUQ5NEQyMTczOUU5AAoJEMzS7ZTSFznp58IP/04XVYxq5JCr7J9oI+Xxu1Se
mQHBtCkKBmydXf1VHYOMUSUZ5bBZeCr8qoJSF3KuO/Pv4T+0U5WsdNFq4njGfJ9s
/8gKTsQoY72tef/kThH1j5TkmqLhweDYegSH4/qUwg9yi+OYKlJu0hT/1+AWT/6a
qXeq21ilyJskRWeTamfnXjqdFc9Rj0gQBHFDk2lbNi+jv6yIJfgGNk78VFtjovoY
rCWFRGiRygb2o5bqeJHKbWWoAfgjNFcppZRYnCBj+/wy5XHQSdGJ2W+W+H3QcaRY
slHZ7f7ysZDKM1uu43L6zj5Aq4hMZlAdLPD19+c8hQ8i4imktQH06DLa5ziXr03q
ketrH6JuoU5ZG/2i/rFG3IoximzeFIFvV2XxVT6a2eNDqHcIhQJF+EGy8OgOnyP+
sX5QRSUXrho2DhKP8Cs1KQQwar5xsHeqm5Nh7d6M36FGlC/ofq9tpSi9+pjh9+T2
sY0J97AHbGqmn0iSdYpncQchPSEVGrAC0zZ34QaORelqjNRDUGf1i5ga0tz6a7wW
Jev3W81TlRI7nni4aIcMMOf7BmyeNBkUcCoufl9lMCphkp9Mr9i/RSk2A+jX0PzT
1ECMnMy7UdHxQzm5gJ+ppFQNSqXHdQqv1nqOvdes/hlFQtCt+i7vJpdwrN56Icq7
RUF29GcSRCkeMyBdr3Vb
=x7mJ
-----END PGP SIGNATURE-----

--------------enig755A19186E46EFA990EBAEC6--
