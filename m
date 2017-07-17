From: David Guyot <david.guyot@europecamions-interactive.com>
Subject: ethtool uselessly tries to retrieve setting from a nonexistent
 device
Date: Mon, 17 Jul 2017 14:42:57 +0200
Message-ID: <1500295377.2016.3.camel@europecamions-interactive.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-SckJFXYeYE77m0Sb/51M"
To: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33912 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751332AbdGQMnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 08:43:09 -0400
Received: by mail-wr0-f196.google.com with SMTP id w4so1032927wrb.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 05:43:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SckJFXYeYE77m0Sb/51M
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello, there.

I noticed a behavior of ethtool 4.8, as used in Debian Stretch, which
could be improved: when I query a nonexistent device, ethtool tries to
retrieve all its settings, even if the first test returns "No such
device". In that case, ethtool should immediatly stop, only saying no
such device, and not calling functions which results are already known.

Hoping my remark is not too naive,

Regards.
--=20
David Guyot
Administrateur syst=C3=A8me=C2=A0/ Sysadmin
Europe Camions Interactive=C2=A0/ Stockway
Moulin Collot F-88500 Ambacourt
T=C3=A9l=C2=A0: +33 (0)3 29 30 47 85
--=-SckJFXYeYE77m0Sb/51M
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEE3x4z121mNEB/JJ/PgVDjr4mKouAFAllssNEACgkQgVDjr4mK
ouAHDxAAh16n52MhF7bkzIC6VJF/ZqdSfPpo5iOoqTI3UuIoqr5OW6CC5YFuHTWv
5blMY5MG60xFeqlrKlIRdmqpN9Ou8cgTx1/wK+4xzaumI+yNDnOkRpOs9utTYtyb
+KGm7DTlbChjWiPbov86U3SUFE4fmDj/9IrI1SdvSjzAZbyoLWyx25Oku66xDAiI
t7/fMwLZaTsR43d4FEmsIPbZn01inSswCvLC09wk/sAGUZGsCc3eBCcrT9MOl6W3
MF//v5YHuVVVTlnNRnN6/iWHibGWGYjsekhD3MTQM+LZUfvSJMh7RM3i00DEUuhQ
czksPnfLPhOV1W7D6F6V+hyyyXy5OiHuvqM5G6AJ6L1QJlrjLX/lTlKkmUoH6aMk
teaCiwhcf5UP/AZPVqfzztTmBrY2xSEmtkvWcSZgsKmEAoi4YkkoGvA0xgpG6QSR
NMIEkTSJgw1mnAHcFZs7/8McsvvwTUOHiSZuYWZ3SvdZxWLwGmugLzhPh2YLKFvn
nntS05+wFiKedvVKxiPSvAIOmzD4PfaU3DVX7gliZIxatkSDD/zrD9DCPi/7pcDO
IpDP2HUsveYXwCWEGBwU31L6JrXqDyzPSh8Pwcud5i59O7Y+9ijdvaKg9LAWwZ9C
vlJTnIAfGW8rFJl15d+Q34N3oSBzhfpPNrbigcPjgqn984SzXhQ=
=tlgI
-----END PGP SIGNATURE-----

--=-SckJFXYeYE77m0Sb/51M--
