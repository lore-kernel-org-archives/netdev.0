From: Mihai Moldovan <ionic@ionic.de>
Subject: Re: iproute2 regression -- ss -u returns an empty list
Date: Tue, 28 Apr 2015 06:33:18 +0200
Message-ID: <553F0D8E.9060602@ionic.de>
References: <553EE0D9.3050601@ionic.de> <20150428040516.GA14129@angus-think.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="VNMoQWju6pfPQN6BvLIbFO5JRM8Kb5bN1"
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from powered.by.root24.eu ([5.135.3.88]:53957 "EHLO Root24.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970AbbD1Ed1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 00:33:27 -0400
In-Reply-To: <20150428040516.GA14129@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--VNMoQWju6pfPQN6BvLIbFO5JRM8Kb5bN1
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 28.04.2015 06:05 AM, Vadim Kochan wrote:> So by default ss prints sock=
et with
CONNECTED state and even UDP can be
> in the CONNECTED state on the Linux,

UDP can be in a CONNECTED state... ooookay. That's probably a conntrack t=
hing.


> so you can specify 'ss -ua' (may be
> some explanation should be added to the ss man page) which
> should print UDP sockets in the any state, AFAIK it was the default
> behaviour before my changes.

Could this please be reverted? It's breaking other stuff that uses ss.

Also: ss -lxua returns an empty list, too. Previously, the families seem =
to have
been OR'd, while they are now ANDed?



Mihai


--VNMoQWju6pfPQN6BvLIbFO5JRM8Kb5bN1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJVPw2PAAoJEB/WLtluJTqHlNQP/j0m9EzimjMeWoryXQg2dg25
egIftJ9IZWCm021jwoR/2nHzupK6Mqbd7LTAj/wUy3fuK+qPd5QYqa+qjhKmmfHc
90ubZxEuCiQRjJVNEYCPhBFrPGbOxWltI/9oVhXd0bWMg94KJmrnEbZ+2cabw347
W5rakNh3diGWrPBQkMNm067NhyUZ9vxa4WSyiNQYIeV4o4WNT5ivMNdYb6hR0xOH
Vod0FqcTlGHCY0CGVcAuoHrlF6qeE48LbKu3rWo0FE+2zgKFaxaU2QEPHuF4NCd+
JeqCjdJ00pzXEEeldCN4JNdbuYr1Ih+6xcW2UqNPMWsNf0c3tOo+1ErZfLVLkOjP
zbm+OdTiQQjhf+8BZJLWhrYAAEYdFrzFRegkIfUu2140plI4EYzsaNukEzTYXjnh
w/9JzjenKDfityPKS4+2wCL+5cmhOQZ7cWUwA2jiVtnQNxRAOKiQIbY6Jnqy2Fpe
a5GYFZOXl5D4fuT0FPOC1aD9sgeP4dufrifMoLOMyVcgBhPYe34h3EvpOT1ZSHTN
SbFP5UIk2QndO9fsIJpCEfi5Do1veulZT3xbdCe/9R2nTo1G1/BROvZJQcpdos5/
9b74FBmsFDYrUM0QgjLO7MLjGZFNIw86aIe3TP4gGxQfvWJRg5hl/utXEtab3oCW
AgiEMV3uDwbikj0p1/RR
=EIzn
-----END PGP SIGNATURE-----

--VNMoQWju6pfPQN6BvLIbFO5JRM8Kb5bN1--
