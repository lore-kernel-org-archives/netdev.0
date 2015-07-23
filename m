From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth 2015-07-23
Date: Thu, 23 Jul 2015 18:17:22 +0300
Message-ID: <20150723151722.GA20850@t440s.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TB36FDmn/VVEgNH/"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35704 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbbGWPSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 11:18:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's another one-patch pull request for 4.2 which targets a potential
NULL pointer dereference in the LE Security Manager code that can be
triggered by using older user space tools. The issue has been there
since 4.0 so there's the appropriate "Cc: stable" in place.

Let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit c5dfd654d0ec0a28fe81e7bd4d4fd984a9855e09:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-07-22 14:45:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 25ba265390c09b0a2b2f3fd9ba82e37248b7a371:

  Bluetooth: Fix NULL pointer dereference in smp_conn_security (2015-07-23 16:41:24 +0200)

----------------------------------------------------------------
Johan Hedberg (1):
      Bluetooth: Fix NULL pointer dereference in smp_conn_security

 net/bluetooth/smp.c | 4 ++++
 1 file changed, 4 insertions(+)

--TB36FDmn/VVEgNH/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVsQWCAAoJECQj9vv5qNQSNYEP/jdc48d4zP0vnFEpD47SBuIn
7KhEr3qAiCkLFUgV8efW0MWcePLhTQZywKZBlszsURKd4eeGuLaUXo8eAjsm+683
f672H4iVcBuQfMFbE1pNbSknX55zpHBD2wlW54FJ6QC5nVxcJzFmUBNCcA4aFHct
nT9SOZOaMU41ZJy7BVhCbW74OB2H3siEftR3aKYE7ol2KEL/vB0Eh0xDZ1zs7CEg
KWtPBQ/5t0SqGnsMeb1CBspsfc8WceSDG1q2JMUGYiX+vhEZO/4Zk5ZXWQuPq1tH
U36S0SnSVjiLqYOleyLvB+R93mdT9eZvZdmw8+AJA6LZH4uhnlpqPraLuZ3iUtcv
AiCGievtSeeom8NvlZTjy3DQRWVvGok4Ubbw8J1fgzD90laNYTL/0PcfA9SpoFt3
YA9cxqP+wdPRZUJ/jbHKpq+CIEl7wANDngSXtwmqVi0lAn/GRIxxPvzPgSCrC4xz
ecxe2fnlNAKs3Mk9i+Vo1I0Ckx7CmjfiAc5F41kqRgyTv021dp466O/ZMxgFlFDX
UhVm09iTtr1wYjfjrbBqBqQfGvuc4G3LGFgtGTq0/dyAA2ut1q2RVjBtefQ9w15/
BMwDTub1h/VzQLxbBcUZ5H/kblzN0x6m5uawdVVxvzRKS9E2SkmLoi5htQbFbH/d
yUGgJXa+kGDePdaHHR89
=T1UA
-----END PGP SIGNATURE-----

--TB36FDmn/VVEgNH/--
