From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 25/29] LMC: Remove unneeded prototypes.
Date: Sat, 31 Jul 2010 17:05:48 +0200
Message-ID: <1280588752-9340-25-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:42188 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756605Ab0GaPG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:26 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/var.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index 206f77a..1f360de 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -427,17 +427,11 @@ static inline void lmc_trace(struct net_device *d=
ev, char *msg)
 }
=20
=20
-int lmc_probe(struct net_device *dev);
-unsigned lmc_mii_readreg(struct card * const sc, unsigned devaddr,
-			 unsigned regno);
-void lmc_mii_writereg(struct card * const sc, unsigned devaddr,
-		      unsigned regno, unsigned data);
 void lmc_led_on(struct card * const, u32);
 void lmc_led_off(struct card * const, u32);
 unsigned lmc_mii_readreg(struct card * const, unsigned, unsigned);
 void lmc_mii_writereg(struct card * const, unsigned, unsigned, unsigne=
d);
 void lmc_gpio_mkinput(struct card * const sc, u32 bits);
 void lmc_gpio_mkoutput(struct card * const sc, u32 bits);
-int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
=20
 #endif /* _LMC_VAR_H_ */
--=20
1.7.1.1

