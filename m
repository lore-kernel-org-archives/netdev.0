From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#625914: linux-image-2.6.38-2-amd64: bridging is not
 interacting well with multicast in 2.6.38-4
Date: Tue, 10 May 2011 03:38:44 +0100
Message-ID: <1304995124.4065.157.camel@localhost>
References: <20110506201234.6297.70279.reportbug@ip6-localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-/rrDfiKxZGFWPYp3hc+z"
Cc: 625914@bugs.debian.org, netdev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Noah Meyerhans <noahm@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54786 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751775Ab1EJCiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 22:38:52 -0400
In-Reply-To: <20110506201234.6297.70279.reportbug@ip6-localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/rrDfiKxZGFWPYp3hc+z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-05-06 at 13:12 -0700, Noah Meyerhans wrote:
> Package: linux-2.6
> Version: 2.6.38-3
> Severity: normal
>=20
> Hi. I've got a system that hosts several kvm virtual hosts.  The VMs
> access the network via tap devices bridged with a physical interface.
> After upgrading to linux-image-2.6.38-2-amd64_2.6.38-4, I noticed that
> the virtualhosts were not autoconfiguring their IPv6 interfaces.
> Debugging revealed that no multicast was passing over the bridge.
>=20
> The bridge configuration is:
> bridge name     bridge id               STP enabled     interfaces
> br0             8000.0002e3080eb5       no              eth1
>                                                         tap0
>                                                         tap1
>                                                         tap2
>=20
> If I attach tcpdump to br0, I can see multicast (e.g. IPv6 Neighbor
> Solicitation) packets.  However, if I attach tcpdump to eth1, I do not
> see multicast packets sourced from one of the VMs.
>=20
> Downgrading to 2.6.38-3 solves the problem.

This is pretty weird.  Debian version 2.6.38-3 has a few bridging
changes from stable 2.6.38.3 and 2.6.38.4, but they don't look like they
would cause this.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-/rrDfiKxZGFWPYp3hc+z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATcilL+e/yOyVhhEJAQrBVQ//QiTMJ9EtgYvtkUtRZDbwcTKNeHBkTmbo
3QDk3ENxcOCHFaibGEF9H2lc8r4Qn0fRhCGhtysTFHA6JFstDrB848N16rgCyjon
PQ5S64I28nMlZfyV/mnd3Hps683/eH0naJlOlunKhZq8cXpZmN+55A9Jq3Fcccbm
fVvZR9BQ3l+dIv9P/eEVd5mloPX3TRqI5dDHVTshEc7Lp89LiIQhqwpBIfPtuqiI
pwn4dhphtpuP3HvbjdlK3dfLnrfa9ce3UIzFzI5QnZLedmvFNd0+yIciDXtsfua5
sz4WcVgAw0/cuVr+v+mguBbKxuaOkUOfdG8bP5NKblU9rUT28riBcoq8xcPvF2+0
zrI2O64rh7WQKzvhAgrhBXC49abcvnbPliXef7MHp88dCulgR+4mYZcripw32Sa4
l9g9FOrwRQKh0j83rkSovC/akCvzD5K/anA4N7McKR0jAhmbsYEDQQDvt023ldU2
PKbVy0Wn0O7SRx5ivssy2TuVGoPefKXbFnazES4JIAd4fblTq2lVn4Q1e5qQCfNC
ySgdwplXqWfAh0CKK+zYkaA2OcIFsUHo3uJ0FmfhxCf6lWzyaKdEV6uOYM+K6E6W
QO/PQ/+homuZN6Xla6fqvgevnWkvLCgI0FMT9TlDnFQc9qXJo2iajVKEX1r7jWgz
sipS362zHQo=
=px4a
-----END PGP SIGNATURE-----

--=-/rrDfiKxZGFWPYp3hc+z--
