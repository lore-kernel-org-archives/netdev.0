From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: [PATCH 2/6] new pcmcia IDs for hostap - D-Link DCF-660W
Date: Tue, 16 May 2006 16:21:16 +0200
Message-ID: <200605161621.17597.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:61138 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S1751136AbWEPOVx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 10:21:53 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I use D-Link DCF-660W card with WPA protected network. By default
orinoco_cs was loaded for my card so I was not able to connect. This patch
make my card working with hostap_cs (like it was when I used pcmcia-cs).
Card was used with hostap_cs during last year in two Zaurus models (2.4.18
on one and 2.6.11 - 2.6.16 on another).

Platform: Sharp Zaurus C760 running 2.6.16 and pcmciautils 013.

root@c7x0:~# pccardctl ident
Socket 0:
  product info: "D-Link", "DCF-660W", "", ""
  manfid: 0xd601, 0x0005
  function: 6 (network)

root@c7x0:~# iwconfig wlan0
wlan0     IEEE 802.11b  ESSID:"test"
          Mode:Master  Frequency:2.422 GHz  Access Point: 00:80:C8:2C:09:3F
          Bit Rate:11 Mb/s   Sensitivity=1/3
          Retry min limit:8   RTS thr:off   Fragment thr:off
          Encryption key:off
          Power Management:off
          Link Quality:0  Signal level:0  Noise level:0
          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          Tx excessive retries:0  Invalid misc:0   Missed beacon:0

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

---
 drivers/net/wireless/hostap/hostap_cs.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:09:25.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:10:37.000000000 +0200
@@ -925,6 +925,8 @@
 		0x273fe3db, 0x32a1eaee),
 	PCMCIA_DEVICE_PROD_ID1234("ASUS", "802_11B_CF_CARD_25", "Version 01.00", "",
 		0x78fc06ee, 0x45a50c1e, 0xa57adb8c, 0x00000000),
+	PCMCIA_DEVICE_PROD_ID12("D-Link", "DCF-660W",
+		0x1a424a1c, 0xe78b6dcc),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);

-- 
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

     You don't have to be crazy to live in this planet, but it helps.
