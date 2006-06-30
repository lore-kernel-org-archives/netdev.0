From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 9/15] pcmcia: hostap_cs.c - 0xc00f,0x0000 conflicts with pcnet_cs
Date: Fri, 30 Jun 2006 21:59:20 +0200
Message-ID: <20060630195920.GJ9095@dominikbrodowski.de>
References: <20060630195107.GA9095@dominikbrodowski.de> <20060630195217.GB9095@dominikbrodowski.de> <20060630195255.GC9095@dominikbrodowski.de> <20060630195358.GD9095@dominikbrodowski.de> <20060630195439.GE9095@dominikbrodowski.de> <20060630195501.GF9095@dominikbrodowski.de> <20060630195600.GG9095@dominikbrodowski.de> <20060630195657.GH9095@dominikbrodowski.de> <20060630195753.GI9095@dominikbrodowski.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jkmaline@cc.hut.fi, hostap@shmoo.com, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.239.214.66]:32955 "EHLO linta.de")
	by vger.kernel.org with ESMTP id S1750841AbWF3UMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 16:12:38 -0400
To: linux-pcmcia@lists.infradead.org
Content-Disposition: inline
In-Reply-To: <20060630195753.GI9095@dominikbrodowski.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Komuro <komurojun-mbn@nifty.com>
Date: Mon, 17 Apr 2006 21:41:21 +0900
Subject: [PATCH] pcmcia: hostap_cs.c - 0xc00f,0x0000 conflicts with pcnet_cs

Comment out the ID 0xc00f,0x0000 in hostap_cs.c, as it conflicts with the
pcnet_cs driver.

Signed-off-by: komurojun-mbn@nifty.com
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/wireless/hostap/hostap_cs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index db03dc2..fbb4189 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -844,7 +844,7 @@ static struct pcmcia_device_id hostap_cs
 	PCMCIA_DEVICE_MANF_CARD(0x02d2, 0x0001),
 	PCMCIA_DEVICE_MANF_CARD(0x50c2, 0x0001),
 	PCMCIA_DEVICE_MANF_CARD(0x50c2, 0x7300),
-	PCMCIA_DEVICE_MANF_CARD(0xc00f, 0x0000),
+/*	PCMCIA_DEVICE_MANF_CARD(0xc00f, 0x0000),    conflict with pcnet_cs */
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0002),
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0005),
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0010),
-- 
1.4.0

