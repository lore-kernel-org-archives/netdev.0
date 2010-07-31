From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 16/29] LMC: Remove unused macros.
Date: Sat, 31 Jul 2010 17:05:39 +0200
Message-ID: <1280588752-9340-16-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:36483 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756564Ab0GaPGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:24 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/var.h |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index 09b901c..f5b233c 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -21,8 +21,6 @@
=20
 #define lmc_csrptr_t		unsigned long
=20
-#define LMC_REG_RANGE		0x80
-
 #define LMC_PRINTF_FMT		"%s"
 #define LMC_PRINTF_ARGS		(sc->lmc_device->name)
=20
@@ -38,8 +36,6 @@
 #define LMC_CSR_READ(sc, csr)		inl((sc)->lmc_csrs.csr)
 #define LMC_CSR_WRITE(sc, reg, val)	outl((val), (sc)->lmc_csrs.reg)
=20
-#define DELAY(n)		SLOW_DOWN_IO
-
 #define lmc_delay()		inl(sc->lmc_csrs.csr_9)
=20
 /* This macro sync's up with the mii so that reads and writes can take=
 place */
@@ -328,9 +324,6 @@ struct card {
 	u32 check;			/* Structure check */
 };
=20
-#define LMC_PCI_TIME		1
-#define LMC_EXT_TIME		0
-
 #define PKT_BUF_SZ		1542
=20
 /* CSR5 settings */
--=20
1.7.1.1

