From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: Re: [PATCH 3/6] new pcmcia IDs for hostap - NETGEAR MA701
Date: Tue, 16 May 2006 16:48:56 +0200
Message-ID: <200605161648.57356.linux-arm@hrw.one.pl>
References: <200605161621.22459.linux-arm@hrw.one.pl> <4469E3F6.5070302@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jouni Malinen <jkmaline@cc.hut.fi>,
	Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:30163 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S1750921AbWEPOtA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 10:49:00 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4469E3F6.5070302@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dnia wtorek, 16 maja 2006 16:38, Jeff Garzik napisa=B3:
> Marcin Juszkiewicz wrote:
> > One more Prism2 card which works with HostAP.
>
> Please roll these into a single patch.  There's no need to split it u=
p
> such that there is one ID per patch.

Index: netdev-2.6/drivers/net/wireless/hostap/hostap_cs.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- netdev-2.6.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 =
16:47:27.469628352 +0200
+++ netdev-2.6/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:47=
:48.882373120 +0200
@@ -881,6 +881,21 @@
 	PCMCIA_DEVICE_PROD_ID12(
 		"ZoomAir 11Mbps High", "Rate wireless Networking",
 		0x273fe3db, 0x32a1eaee),
+	PCMCIA_DEVICE_PROD_ID1234("ASUS", "802_11B_CF_CARD_25", "Version 01.0=
0", "",
+		0x78fc06ee, 0x45a50c1e, 0xa57adb8c, 0x00000000),
+	PCMCIA_DEVICE_PROD_ID12("D-Link", "DCF-660W",
+		0x1a424a1c, 0xe78b6dcc),
+	PCMCIA_DEVICE_PROD_ID12("NETGEAR", "MA701 Wireless CF Card",
+		0x9aa79dc3, 0xd9ec98e),
+	PCMCIA_DEVICE_PROD_ID12("PLANEX COMMUNICATION INC",=20
+			"PLANEX GW-CF11X Wireless CF Card",
+			0x4703cf68, 0xfad7318d),
+	PCMCIA_DEVICE_PROD_ID123(
+			"Pretec", "CompactWLAN Card 802.11b", "2.5",
+			0x1cadd3e5, 0xe697636c, 0x7a5bfcf1),
+	PCMCIA_DEVICE_PROD_ID1234(
+		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02", ""
+		0xc7b8df9d, 0x1700d087, 0x4b74baa0, 0x00000000),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);


--=20
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

                        If it works, don't fix it.
                        		-- Sam Rayburn
