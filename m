From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: Web10g TCP statistics patch - mainlining into kernel?
Date: Fri, 25 Jan 2013 13:31:56 -0500
Message-ID: <18855.1359138716@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1359138716_1992P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	web10g-user@web10g.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1359138716_1992P
Content-Type: text/plain; charset=us-ascii

I had a user who's working on tuning high-performance network file systems what
the chances of upstreaming the Web10G patch to provide the RFC4898 TCP Extended
Statistics MIB via netlink.

Yes, it's a tad on the intrusive side, and there's performance costs attached -
but so are a lot of *other* things that people use all the time for kernel
debugging, and it's a zero-hit thing for people who don't choose to configure
it into their kernel.  The added detailed status available from this will be
useful for people who are doing tuning and development (consider how useful
this would have been for the people who wrote the codel line discipline as part
of the bufferbloat project).

I'm willing to do the not-so-heavy lifting of getting the existing patch
cleaned up to upstream standards and sheparded through the process, if there's
any interest at all....


--==_Exmh_1359138716_1992P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUQLPnAdmEQWDXROgAQLfRQ//XN6C0Bt03dDBuQsk0f9MnYMM4A6eziKc
9qAgg2JDhgRAig2rjKp0StDdVa1tc8OfuKqlgUrMIdK92v8RqysOOaZezM2EcLaf
DJT+eDeEiDBRdIxJVyGwR65pOpdsTaDyQlo6fGXHya5DEwKIxw8CUsCSxguhYmeW
U2OORG2Pw2nbDIyk46nEbL9XT56x8PJYyNDdoN9wZoUMC9oTIg9x4Ux+KHq5l+PF
Ss6CR6UXPaBP9wn5V12mrihgXKxx59axl54dOaWKtWxf03YiJ2r9U9aoTt3daMrp
Ij1BOZaBOS8iaMmXJhVV+DMtMclytWGUP6mI3FiCKjS7uL3V7r0dLsGhFPsy4P3V
w+11O1hJGhf3KdiZf4PcAGnLvAAwaBqPnjWNnPbdoxfHh51EJswiedKq5lygcWUz
zJFvoWKBTV+vTZv1BFQVoYA1UNMhQyHnMDzrPtGfmO1XvEJvm1v7l51QAg3O1p3B
CUG4tnAPR5uaFpg12xozjkCPwDDCEnqok78fHpaRnbOMFeEUlmuUN+m2G4/2la+X
0XYLQq1vUkRxT1Jr4SKFD1yJGsSSI2dfTWtdiiMQ4BJhScBFR8ScEQ4Lomull4qQ
1xoa54mN1P94vssPntMdxY1lC77fvN/rs4k/EHxNmGumTeJAgL2hYioQh7dASXdh
8TEUzmlsQ+4=
=cNxN
-----END PGP SIGNATURE-----

--==_Exmh_1359138716_1992P--
