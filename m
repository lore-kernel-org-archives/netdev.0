From: Valdis.Kletnieks@vt.edu
Subject: 2.6.23-mm1 tg3 wake-on-lan oddity...
Date: Tue, 27 Nov 2007 04:35:18 -0500
Message-ID: <24400.1196156118@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1196156118_2790P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:34851 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbXK0JfU (ORCPT
	<RFC822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 04:35:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1196156118_2790P
Content-Type: text/plain; charset="us-ascii"
Content-Id: <24394.1196156118.1@turing-police.cc.vt.edu>

Scenario - Dell Latitude D820 laptop, tg3 driver says this at boot:

eth0: Tigon3 [partno(BCM5752KFBG) rev 6002 PHY(5752)] (PCI Express) 10/100/1000Base-T Ethernet 00:15:c5:c8:33:4e
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
eth0: dma_rwctrl[76180000] dma_mask[64-bit]

# (lspci; lspci -n) | grep 09
09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5752 Gigabit Ethernet PCI Express (rev 02)
09:00.0 0200: 14e4:1600 (rev 02)

(I think that's most of the likely-relevant info...)

Issue:

I (for unrelated reasons) run powertop, and it suggests I conserve power
by doing 'ethtool -s eth0 wol d'.  I look at it, and think that it's daft,
because (a) the Dell factory default is WOL disabled and (b) if it wasn't
the default, I'd have *set* it to disabled, and (c) I even went back and
rebooted and checked the BIOS setting - disabled. Nonetheless:

# ethtool eth0 | grep Wake
        Supports Wake-on: g
        Wake-on: g

Is this expected behavior?

--==_Exmh_1196156118_2790P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHS+TWcC3lWbTT17ARApEWAKDWCl3iX1sGcQLMS80cIblSREuOfwCgiWWc
pzMcG2P9/3vRFPIfghy3Rz0=
=L00V
-----END PGP SIGNATURE-----

--==_Exmh_1196156118_2790P--
