From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] bnx2x: Update to FW 7.8.19
Date: Sun, 09 Feb 2014 13:20:43 +0000
Message-ID: <1391952043.25202.58.camel@deadeye.wl.decadent.org.uk>
References: <1390921061-22019-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LCoMxvdeWzZXIlJBuMnJ"
Cc: dwmw2@infradead.org, netdev@vger.kernel.org,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40533 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396AbaBINUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 08:20:55 -0500
In-Reply-To: <1390921061-22019-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LCoMxvdeWzZXIlJBuMnJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-01-28 at 16:57 +0200, Yuval Mintz wrote:
> This new firmware fixes several bugs:
>  1. HW attention appears and traffic stops when iSCSI firmware tries to
>     retransmit iSCSI login command when the iSCSI login is carrying data
>     not aligned to 4-bytes.
>  2. FCoE traffic fails to run when running in switch-independent multi-fu=
nction
>     mode and there's more than one interface supporting FCoE on a given p=
ort.
>  3. While two ports are running FCoE with at least one of them has a func=
tion
>     number (>1) on the same engine in a 4-port device a zeroed CQE is giv=
en,
>     causing FCoE traffic to stop.
>=20
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
[...]

Applied.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-LCoMxvdeWzZXIlJBuMnJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUveAq+e/yOyVhhEJAQpT3Q//XCYh5Tq89XSBnSUOcJr4Y/6YMxp7t5h1
XM0lggSIa5ToL0PgIXgW9z/gRm6O4fyageiNv7RIgzGxJ17aSE9JBMChwl02U75H
o5uLTBg5GFuYC1DIpyfbxOsx7h4iPaKdeE94N3yoRWJAbSAGPnOzvQ6KWYcYjgsW
mAyUU1+FCVGaTFyJnZkjEyS1et1IgVjlDacBQBI/jLWYDMGSYs6NeaD2vmAYSWeg
BNWdkXYrgED5b28IygM39TEPyYDtvdwsgPZ9X5LFjaeRkRpDVDS9h1HLfOBWnFX2
BsdcrZqlkCJ1rhD1iMw7Kwiz3cMw/9uSfe31JEiZrzWRfhAf/R2TeINVTGr15QGC
VwJ8OyjDQq3c+rZhTrwcNdtgFnbq5lKfzle8YypVysHaiBBxXqHdC2PNJ0y/6oAF
oCmkmgW1oN/7j/AZh9LHu3s/CQfvnuF78RxJttaMCCkEP67f0dCDF+NUS1rtxIMY
NRj0ROFS1ptt25zv/HbbR3KH2JSMX1kwsta+OVcRklf9Sshv/lKFXlbNWg804/1K
l2n2EDQeEWovm4edqIn2YcO4gAqftBD7lKCN5rX50vyv1F5O82FoqqImUitQbPkx
oJs2BjrxkrvBXgElJ/WWnRqpHBDyFG+5zzoLkvltmKWp/Zo98Y1Z3jG7Fnj+k39+
XMmmNaFyp/g=
=R+dn
-----END PGP SIGNATURE-----

--=-LCoMxvdeWzZXIlJBuMnJ--
