From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth 2015-02-23
Date: Mon, 23 Feb 2015 09:45:26 +0200
Message-ID: <20150223074526.GA8287@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jI8keyz6grp/JLjh"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:38211 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbbBWHph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 02:45:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's one important fix for the 4.0-rc series. Refactoring of Intel
Bluetooth controller detection ended up disabling some older ones which
are based on CSR hardware. This patch re-introduces the necessary USB id
and fixes the breakage.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 6514890f7aa8dd75fa46e282a1c7a8615e86f363:

  tcp: fix tcp_should_expand_sndbuf() to use tcp_packets_in_flight() (2015-02-22 23:07:11 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 407550fe2ccfca3fa0ac4bcdb0a412adeabf84ba:

  Bluetooth: btusb: Fix issue with CSR based Intel Wireless controllers (2015-02-23 09:30:35 +0200)

----------------------------------------------------------------
Marcel Holtmann (1):
      Bluetooth: btusb: Fix issue with CSR based Intel Wireless controllers

 drivers/bluetooth/btusb.c | 1 +
 1 file changed, 1 insertion(+)


--jI8keyz6grp/JLjh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJU6tqWAAoJECQj9vv5qNQSFLwP/2kQUHsh3VbXoo2q/jAUWamA
LJT0mJYAf7fpvDVvaiSaAGm9eFZrmQsCduTY+GZRkILX5B/LqCmtrr1eLoOBjDjR
e7BzA3PpK29cxsnh9uyRr3VG/GKB4GsZYLpoNGQr47x0PCilehv/m428wIf0y0HI
NI7VKODFvnhK1Mzj2msYSp1wGEScu/XprGirz3i1oZlf/e9ery6j8y92PiRx+KQ3
Fd4WKf11Wxow11bIwi2A+0VmG0bL6etTU4b8ijSeVI8FtY+27QVFxVcj7oLC7c4e
xWhfpclt7IMzsHVO5L9WlNAo8miLAyjQ/rXS1Wt/A/fz/GfKYa4XaWyso/T01XlT
jNHqrVjXO1XEh2bFbTjgGVbcSu7EQZ1X/hv2CRKs0TvlZt+tS5+E3bzBqedAxFxz
fzrbca41JrRFYpu6qOIw1Rv21rxzYspkghNiKwzaQFc1ugflrjdUz2I8iu6Q9aBB
3ueiZVDKY7Fd0msofVzV5M8UG1rLogQwwm65B3luMdKu8UtO8zZH6E8Tdof2lDxk
Y5ogWT2Et0PCFusQn837cyHdwg4Z6VZXD8M3FqS/wFmdcSS4qTNKRZu9BwkU4eqN
/bCqI2yDpj41kaKISqBXo6t/InwRLmYclZ5eB9ibSTwRtFSKgasTcWpzjptqso8U
/Ovt4A7kGGX++5SN67/1
=n+E9
-----END PGP SIGNATURE-----

--jI8keyz6grp/JLjh--
