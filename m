From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Fix Warnings from net/netlink/genetlink.c
Date: Tue, 11 Aug 2009 11:11:16 +0200
Message-ID: <1249981876.3015.0.camel@johannes.local>
References: <1249975630.2400.7.camel@HunTEr>
	 <1249976174.5903.16.camel@johannes.local> <1249982110.13065.7.camel@HunTEr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-qA61pkx22KGyWYurO6ck"
Cc: linux-next@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: vibi_sreenivasan@cms.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1249982110.13065.7.camel@HunTEr>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-qA61pkx22KGyWYurO6ck
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,


> > > net/netlink/genetlink.c: In function `genl_register_mc_group':
> > > net/netlink/genetlink.c:139: warning: 'err' might be used uninitializ=
ed in this function
> >=20
> > Well, only if there's no netns which can't happen.

> 	So how to silence that warning?

Well, I suppose your patch is the best way anyhow, using
uninitialized_var() would seem somewhat dangerous for future
modifications of the function.

johannes

--=-qA61pkx22KGyWYurO6ck
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKgTWwAAoJEODzc/N7+QmaSScP/0WEjBjwyXnYIb72HbnUDNU4
rFlKDyg8/KDUxfisT5zcg3P0N5t/0zQ8WvDrZq1GQ7dNPioV+jXREgSTn+mv6NJZ
MJ6pbyxoTtAN9DArFp1byLNLZJAOBeTAB4cDJrl9z6zEVzw0HGkCxueTG1V6bBUF
Sz80jKMdgjN98I0SuAeOrVgse0tI+phi8faa6qYSWILQMjmAmS70TWhY2l1bkizq
Aqs/H/kcWficBcQY5rGfn4n/1dkBqVOhgmOwT/yGPenzPsNg1Z95NZt75m0rnUYf
j5OvWGvFcmC2LzJ+Cs+Jr8c1jeKQnh93zp3dlQyGQDuoIdIII5kRFgI3FMgfEN5t
nuQ5TVBOY4Whfs4mCtg7a3mbqpVILf3t0t7rBcHWIwUYdQMNGKdLqag/T1k+qYs7
rlSm9Ktckc4lxW3WbkrKKSGqrDMr3zNfcnRo5VOmuzaUeJ7m5vO2zk2JJj7p/KGT
+flLA5cxomHbPDxQJL1tubt8Wpo+32jgLbQwS3YUWeyKxmlszGVukxPHR+aEHN6f
VkCwhXJHgrbyIQNcIx/owE/+K4iEtwjvw3vRGNDj2xqwY3ULTTAcFzm1/C0zOWy4
0suW23GuP2jblndjNKAvI9JfdC/xzUiJMqV4zay+yDfX8cLyypvk7BDhv3GAlrL8
VSi61mWrYiFXkQUHyoY2
=+Rhc
-----END PGP SIGNATURE-----

--=-qA61pkx22KGyWYurO6ck--
