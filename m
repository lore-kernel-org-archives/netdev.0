From: Daniele Venzano <venza@brownhat.org>
Subject: [PATCH] Add new PHY to sis900 supported list
Date: Sat, 12 Aug 2006 11:17:03 +0200
Message-ID: <20060812091703.GA741@renditai.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="5mCyUwZo2JvN/JJP"
Cc: Jools Smyth <jools@oxfordinspire.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-174-42-79.f5.ngi.it ([81.174.42.79]:65190 "HELO
	renditai.milesteg.arr") by vger.kernel.org with SMTP
	id S1751373AbWHLJRP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 05:17:15 -0400
To: NetDev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Please include the attached patch that adds support for a new PHY to the
sis900 driver. See also Bugzilla 6919.

Signed-off-by: Daniele Venzano <venza@brownhat.org>

-- 
------------------------------
Daniele Venzano
Web: http://teg.homeunix.org

--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch.diff"

diff -urN linux-source-2.6.15/drivers/net/sis900.c linux-src-modified/drivers/net/sis900.c
--- linux-source-2.6.15/drivers/net/sis900.c	2006-03-02 21:18:37.000000000 +0000
+++ linux-src-modified/drivers/net/sis900.c	2006-07-29 14:46:51.000000000 +0100
@@ -131,6 +131,7 @@
 	{ "AMD 79C901 10BASE-T PHY",  		0x0000, 0x6B70, LAN },
 	{ "AMD 79C901 HomePNA PHY",		0x0000, 0x6B90, HOME},
 	{ "ICS LAN PHY",			0x0015, 0xF440, LAN },
+	{ "ICS LAN PHY",			0x0143, 0xBC70, LAN },
 	{ "NS 83851 PHY",			0x2000, 0x5C20, MIX },
 	{ "NS 83847 PHY",                       0x2000, 0x5C30, MIX },
 	{ "Realtek RTL8201 PHY",		0x0000, 0x8200, LAN },

--5mCyUwZo2JvN/JJP--
