From: akpm@osdl.org
Subject: [patch 07/10] atmel_cs: Add support LG LW2100N WLAN PCMCIA card
Date: Mon, 24 Jan 2005 18:57:14 -0800
Message-ID: <200501250257.j0P2vgl20272@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, justman@e1.bmstu.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: JustMan <justman@e1.bmstu.ru>

Add support for the LG LW2100N 11Mbps WLAN PCMCIA card 

Signed-Off-By: Serge A. Suchkov <justman@e1.bmstu.ru>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/wireless/atmel_cs.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/wireless/atmel_cs.c~atmel_cs-add-support-lg-lw2100n-wlan-pcmcia-card drivers/net/wireless/atmel_cs.c
--- 25/drivers/net/wireless/atmel_cs.c~atmel_cs-add-support-lg-lw2100n-wlan-pcmcia-card	2005-01-24 18:55:47.575064328 -0800
+++ 25-akpm/drivers/net/wireless/atmel_cs.c	2005-01-24 18:55:47.578063872 -0800
@@ -328,7 +328,8 @@ static struct { 
 	{ 0, 0, "CNet/CNWLC 11Mbps Wireless PC Card V-5", "atmel_at76c502e%s.bin", "CNet CNWLC-811ARL" },
 	{ 0, 0, "Wireless/PC_CARD", "atmel_at76c502d%s.bin", "Planet WL-3552" },
 	{ 0, 0, "OEM/11Mbps Wireless LAN PC Card V-3", "atmel_at76c502%s.bin", "OEM 11Mbps WLAN PCMCIA Card" },
-	{ 0, 0, "11WAVE/11WP611AL-E", "atmel_at76c502e%s.bin", "11WAVE WaveBuddy" } 
+	{ 0, 0, "11WAVE/11WP611AL-E", "atmel_at76c502e%s.bin", "11WAVE WaveBuddy" },
+	{ 0, 0, "LG/LW2100N", "atmel_at76c502e%s.bin", "LG LW2100N 11Mbps WLAN PCMCIA Card" },
 };
 
 static void atmel_config(dev_link_t *link)
_
