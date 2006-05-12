From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: [PATCH 4/5] new pcmcia IDs for hostap - Netgear MA701
Date: Fri, 12 May 2006 15:48:39 +0200
Message-ID: <200605121548.40566.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:3521 "EHLO smtp.host4.kei.pl")
	by vger.kernel.org with ESMTP id S1751299AbWELNsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 09:48:46 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One more Prism2 card which works with HostAP.

Platform: Sharp Zaurus SL-5500 running 2.4.18 + hostap_cs 0.4.7

root@collie:~# cardctl ident
Socket 0:
  product info: "NETGEAR", "MA701 Wireless CF Card", ""
  manfid: 0xd601, 0x0002
  function: 6 (network)

root@collie:~# ifconfig wlan0
wlan0     Link encap:Ethernet  HWaddr 00:0F:B5:DE:41:CE
          inet addr:135.82.8.139  Bcast:135.82.255.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:56 errors:0 dropped:0 overruns:0 frame:0
          TX packets:40 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:7449 (7.2 KiB)  TX bytes:7250 (7.0 KiB)
          Interrupt:35

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:43:36.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:46:35.000000000 +0200
@@ -976,6 +976,8 @@
 				0x0733cc81, 0x0c52f395),
  	PCMCIA_DEVICE_PROD_ID12("D-Link", "DCF-660W",
 				0x1a424a1c, 0xe78b6dcc),
+ 	PCMCIA_DEVICE_PROD_ID12("NETGEAR", "MA701 Wireless CF Card",
+				0x9aa79dc3, 0xd9ec98e),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);

-- 
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

          Monday is a hard way to spend one-seventh of your life.
