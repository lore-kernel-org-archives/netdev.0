From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the driver-core tree
Date: Mon, 21 Feb 2011 17:02:26 +1100
Message-ID: <20110221170226.c43175f7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__21_Feb_2011_17_02_26_+1100_zuUUFtN+lJFISuP."
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Ilya Yanok <yanok@emcraft.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:53441 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528Ab1BUGCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Feb 2011 01:02:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__21_Feb_2011_17_02_26_+1100_zuUUFtN+lJFISuP.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

After merging the driver-core tree, today's linux-next build (x86_64
allmodconfig) produced this warning:

drivers/net/dnet.c: In function 'dnet_mii_init':
drivers/net/dnet.c:340: warning: passing argument 1 of 'platform_set_drvdat=
a' from incompatible pointer type
include/linux/platform_device.h:138: note: expected 'struct platform_device=
 *' but argument is of type 'struct net_device *'

Revealed by commit 71d642908d4e8e7a2a4a6e0490432e719ff466d5 ("Driver
core: convert platform_{get,set}_drvdata to static inline functions").
Introduced by commit 4796417417a62e2ae83d92cb92e1ecf9ec67b5f5 ("dnet:
Dave DNET ethernet controller driver (updated)").
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__21_Feb_2011_17_02_26_+1100_zuUUFtN+lJFISuP.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNYf/yAAoJEDMEi1NhKgbszosH/3TrbJUsYqDikPQFxnk1FuAm
AfB7gonSdoDfT0kF1Q0c0V3h3sRKiHA175kkV3Hq9olbjsqKgYLbfB6JHznV8iTL
l/Nd4RXlTTHiUPu2q2x3cI/fNMPE20dAaipuBYHa72qH6rNZ3JFjyqlqToPG4/IX
Vd5x5hWZ5nyuxZ0vV8ARz4kHpgNZv4cbaLRq3E/t2zqFKEGcrp5rtqkoxhHYP5Ow
+rPg7zLVPXB2r0xegwDvDr2v8VtPJ36h80bveUA1b9xNZh43oqufEZvt5djDlh27
c4krt+iD9bJbEfsgnc943Q3yYlRD8OPbBqeWoNZxWH1mIJgvrYCSMRdbTmRoGR0=
=ebad
-----END PGP SIGNATURE-----

--Signature=_Mon__21_Feb_2011_17_02_26_+1100_zuUUFtN+lJFISuP.--
