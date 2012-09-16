From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 0/6] llc2: Simplify llc_station
Date: Sun, 16 Sep 2012 04:09:42 +0100
Message-ID: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bsqH9MtcJMMWmGRu/J5S"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52997 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750865Ab2IPDJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 23:09:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bsqH9MtcJMMWmGRu/J5S
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

There seem to have been some grand plans for llc_station, but as they
haven't been fulfilled it's just unnecessarily complicated.

Ben.

Ben Hutchings (6):
  llc2: Remove pointless indirection through llc_stat_state_trans_end
  llc2: Remove dead code for state machine
  llc2: Collapse the station event receive path
  llc2: Remove the station send queue
  llc2: Remove explicit indexing of state action arrays
  llc2: Collapse remainder of state machine into simple if-else
    if-statement

 net/llc/llc_station.c |  600 +--------------------------------------------=
----
 1 file changed, 9 insertions(+), 591 deletions(-)


--=20
Ben Hutchings
Experience is what causes a person to make new mistakes instead of old ones=
.

--=-bsqH9MtcJMMWmGRu/J5S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUFVC9ue/yOyVhhEJAQqprhAAu/y8bQFx/BZlN6TlGuEPHFo232x716mY
I/jN+eMyZREvmutI2ZorW9wnvJGXoeWDIK9QrYQgnBpo7STV8hZm9QXJPyyJQ7mg
bIJ7jF6UJk5fwZIr02jUNNU4gEfocIG14pv0DEkW20gDOco031N9Y5eGawvUMabu
yI8T1GCSVrp6TxhL94/lEFNsKF51hzcoqEBfXdY0CjBiqJUBDLqmc2kIJ56KnS0o
6LaBnDUAqfyKua1Bi3DR8XYrgV0gXE4OTPSz5TuAmoc4Xq76j2+Ug0Ss8V7KD3s2
OJZri4T+TGL/BoNK6eoors6Bte4R9+AODp0Jbfpkh4GE4qSufhgfveZ+JQlkFQIG
OcB6tqEXVe4JAgNDNFqT8PWF63xRcyexIzC9Joa2lFJGtFbuF483PjEVmsY3bpRZ
Ap6ivKkwatvfvJwsIiXRrkkBaKc4roYsOukMLrpxFOW3wh+hdMqhyw3si1nkG1Ss
qlB2r6COMG3G+16oW9Zbdr5lUD5TSwqrWonPrM2VB8porTgHiNkfIVdoaU06PJtq
5Gdimy2Je2lyJOplodgy88H2cRiLyGwl2nEPU2XmHDRHeqmB/i1mEbjUOK50aVhc
sJmM4LFlkLi4seXMJx2hqJW0q/JjlFnAJcW6Wt0H7GXCpolu+DOltdgJnnsmVEOa
Fxs0YMJ03iM=
=XuyI
-----END PGP SIGNATURE-----

--=-bsqH9MtcJMMWmGRu/J5S--
