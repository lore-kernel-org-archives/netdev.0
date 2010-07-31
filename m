From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 26/29] LMC: Remove redundant macro.
Date: Sat, 31 Jul 2010 17:05:49 +0200
Message-ID: <1280588752-9340-26-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:37675 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756508Ab0GaPGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:24 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/var.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index 1f360de..54e9b0b 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -396,10 +396,6 @@ struct card {
 #define DESC_OWNED_BY_SYSTEM	((u32)(0x00000000))
 #define DESC_OWNED_BY_DC21X4	((u32)(0x80000000))
=20
-#ifndef TULIP_CMD_RECEIVEALL
-#define TULIP_CMD_RECEIVEALL	0x40000000L
-#endif
-
 /* Adapter module number */
 #define LMC_ADAP_HSSI		2
 #define LMC_ADAP_DS3		3
--=20
1.7.1.1

