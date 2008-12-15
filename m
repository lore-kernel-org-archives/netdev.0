From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Phonet: improve GPRS variable names
Date: Mon, 15 Dec 2008 16:06:10 +0200
Message-ID: <200812151606.10477.remi.denis-courmont@nokia.com>
References: <> <1229349724-12905-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:26943 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbYLOOHp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 09:07:45 -0500
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mBFE7W00014115
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 16:07:42 +0200
Received: from esdhcp041160.research.nokia.com (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int02.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mBFE6A60008772
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 16:06:10 +0200
In-Reply-To: <1229349724-12905-1-git-send-email-remi.denis-courmont@nokia.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That depends on the earlier Phonet patch in net-2.6.
I resolved the merge this way (but I could be wrong):

diff --cc drivers/net/e1000e/ich8lan.c
index 92f2ace,d115a6d..0000000
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@@ -1939,7 -1893,8 +1939,8 @@@ static s32 e1000_reset_hw_ich8lan(struc
  		ctrl |=3D E1000_CTRL_PHY_RST;
  	}
  	ret_val =3D e1000_acquire_swflag_ich8lan(hw);
+ 	/* Whether or not the swflag was acquired, we need to reset the part=
 */
 -	hw_dbg(hw, "Issuing a global reset to ich8lan");
 +	hw_dbg(hw, "Issuing a global reset to ich8lan\n");
  	ew32(CTRL, (ctrl | E1000_CTRL_RST));
  	msleep(20);
 =20


--=20
R=C3=A9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
