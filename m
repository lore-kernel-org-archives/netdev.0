From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [RFC PATCH 2/11] pcmcia: add more IDs to hostap_cs.c
Date: Wed, 25 Oct 2006 22:12:37 -0400
Message-ID: <20061026021237.GC20473@dominikbrodowski.de>
References: <20061026021027.GA20473@dominikbrodowski.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	hostap@shmoo.com, linville@tuxdriver.com, jkmaline@cc.hut.fi,
	proski@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.239.214.66]:36831 "EHLO linta.de")
	by vger.kernel.org with ESMTP id S965286AbWJZCTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 22:19:11 -0400
To: linux-pcmcia@lists.infradead.org
Content-Disposition: inline
In-Reply-To: <20061026021027.GA20473@dominikbrodowski.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dominik Brodowski <linux@dominikbrodowski.net>
Date: Sun, 2 Jul 2006 21:21:51 +0200
Subject: [PATCH] pcmcia: add more IDs to hostap_cs.c

As a replacement for the broad manufactor/card ID match we commented out
because of conflicts with pcnet_cs, add two product ID matches.

Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/wireless/hostap/hostap_cs.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 686d895..f63909e 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -887,6 +887,13 @@ static struct pcmcia_device_id hostap_cs
 	PCMCIA_DEVICE_PROD_ID123(
 		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02",
 		0xc7b8df9d, 0x1700d087, 0x4b74baa0),
+	PCMCIA_DEVICE_PROD_ID123(
+		"Allied Telesyn", "AT-WCL452 Wireless PCMCIA Radio",
+		"Ver. 1.00",
+		0x5cd01705, 0x4271660f, 0x9d08ee12),
+	PCMCIA_DEVICE_PROD_ID123(
+		"corega", "WL PCCL-11", "ISL37300P",
+		0xa21501a, 0x59868926, 0xc9049a39),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);
-- 
1.4.3

