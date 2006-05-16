From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: [PATCH 1/6] new pcmcia IDs for hostap - ASUS WL-110
Date: Tue, 16 May 2006 16:21:13 +0200
Message-ID: <200605161621.14585.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:60882 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S1751138AbWEPOVx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 10:21:53 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's another card that would benefit from a hostap driver:

Platform: HP Ipaq hx4700 running 2.6.16-hh

root@ipaq-pxa270:~# pccardctl ident
Socket 0:
  product info: "ASUS", "802_11B_CF_CARD_25", "Version 01.00", ""
  manfid: 0x02aa, 0x0002
  function: 6 (network)

root@ipaq-pxa270:~# ifconfig wlan0
wlan0     Link encap:Ethernet  HWaddr 00:0C:6E:F0:DA:CD
          inet addr:172.20.0.3  Bcast:172.20.255.255  Mask:255.255.0.0
          inet6 addr: 2001:610:600:93:20c:6eff:fef0:dacd/64 Scope:Global
          inet6 addr: fe80::20c:6eff:fef0:dacd/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:158 errors:0 dropped:0 overruns:0 frame:0
          TX packets:77 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:17978 (17.5 KiB)  TX bytes:11424 (11.1 KiB)
          Interrupt:92

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

---
 drivers/net/wireless/hostap/hostap_cs.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:08:25.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:10:38.000000000 +0200
@@ -923,6 +923,8 @@
 	PCMCIA_DEVICE_PROD_ID12(
 		"ZoomAir 11Mbps High", "Rate wireless Networking",
 		0x273fe3db, 0x32a1eaee),
+	PCMCIA_DEVICE_PROD_ID1234("ASUS", "802_11B_CF_CARD_25", "Version 01.00", "",
+		0x78fc06ee, 0x45a50c1e, 0xa57adb8c, 0x00000000),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);

-- 
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

             I do not fear computers. I fear the lack of them.
             		-- Isaac Asimov
