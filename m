From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc 2012-02-25
Date: Sat, 25 Feb 2012 01:11:17 +0000
Message-ID: <1330132277.2397.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-z6uS9SVh2+0kR6fGQPdV"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:62574 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757035Ab2BYBL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 20:11:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-z6uS9SVh2+0kR6fGQPdV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 8a49ad6e89feb5015e77ce6efeb2678947117e20=
:

  ppp: fix 'ppp_mp_reconstruct bad seq' errors (2012-02-24 17:53:21 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.3

(commit ff3bc1e7527504a93710535611b2f812f3bb89bf)

Fixes incorrect marking of skbs as checksummed.  Please send this on to
stable as well; the bug was introduced in 2.6.37.

Ben.

Ben Hutchings (1):
      sfc: Fix assignment of ip_summed for pre-allocated skbs

 drivers/net/ethernet/sfc/rx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.




--=-z6uS9SVh2+0kR6fGQPdV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJPSDU1AAoJEGkILBsOca60yAEH+gNQdI7Srdwr2vOrLRfnaJe2
8rsRv3E7NOKaytOTQgtFMPQV82CCAKyx9yojaJLj7k4hiqmeTf1LfoqELMBJ8HtN
/APaZMJu+qlaCtsT10d67i8h9MDRnHXBsW7ls9FZ1Xm6+0bMDKyk9R244+14i4jv
INNC2aiZhExTqNpZ+qyQDkLkpYFYFgWboGeWu/It/egC234dlqGWhSziIUtAy4BE
4OSJfmhYWt6e8NB1Y30H8UCWETzfBOGIO5cVs+hkrnwSpEjK5gf8ZTNXD8b7yEm9
mvb5FMyq/CzNnie3yje6UtzCq+zWyqKSwkyIEVJmzrpuZ4CVy0KicdB4x0FyNlQ=
=N/mz
-----END PGP SIGNATURE-----

--=-z6uS9SVh2+0kR6fGQPdV--
