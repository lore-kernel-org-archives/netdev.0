From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 2/6] rt2x00 update: Deactivate monitor_during_oper for now
Date: Fri, 28 Apr 2006 16:52:26 +0200
Message-ID: <200604281652.27149.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6828701.gBFqCU93oe";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:61151 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S965217AbWD1Ov0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 10:51:26 -0400
Received: by nproxy.gmail.com with SMTP id n29so1594528nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 07:51:25 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6828701.gBFqCU93oe
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Set monitor_during_oper to 0 for the time being,
this feature will be supported in the future.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-28 15:13:49.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-28 15:16:23.000000000 +0200
@@ -2362,7 +2362,7 @@ rt2400pci_init_hw(struct rt2x00_pci *rt2
 	hw->no_tkip_wmm_hwaccel =3D 1;
 	hw->extra_hdr_room =3D 0;
 	hw->device_strips_mic =3D 0;
=2D	hw->monitor_during_oper =3D 1;
+	hw->monitor_during_oper =3D 0;
 	hw->fraglist =3D 0;
=20
 	/*
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-28 15:12:23.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-28 15:16:23.000000000 +0200
@@ -2619,7 +2619,7 @@ rt2500pci_init_hw(struct rt2x00_pci *rt2
 	hw->no_tkip_wmm_hwaccel =3D 1;
 	hw->extra_hdr_room =3D 0;
 	hw->device_strips_mic =3D 0;
=2D	hw->monitor_during_oper =3D 1;
+	hw->monitor_during_oper =3D 0;
 	hw->fraglist =3D 0;
 	hw->channel_change_time =3D 2000;
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-28 15:13:01.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-28 15:16:22.000000000 +0200
@@ -2233,7 +2233,7 @@ rt2500usb_init_hw(struct rt2x00_usb *rt2
 	hw->no_tkip_wmm_hwaccel =3D 1;
 	hw->extra_hdr_room =3D 0;
 	hw->device_strips_mic =3D 0;
=2D	hw->monitor_during_oper =3D 1;
+	hw->monitor_during_oper =3D 0;
 	hw->fraglist =3D 0;
 	hw->channel_change_time =3D 500000;
=20

--nextPart6828701.gBFqCU93oe
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUiwraqndE37Em0gRArEbAKCdjvsF9cJY26pzZgEGel8thrDexACgqh9j
qwvmYTgDYxKZlzYN4jbq+1o=
=dHUQ
-----END PGP SIGNATURE-----

--nextPart6828701.gBFqCU93oe--
