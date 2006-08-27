From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 8/10] rt2x00: change variable name
Date: Sun, 27 Aug 2006 17:39:15 +0200
Message-ID: <200608271739.15534.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:42540 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932145AbWH0Pj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 11:39:26 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1091663nfa
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 08:39:26 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When setting the ARCSR registers we could use a better/more descriptive
and already available variable name than plain "value".

Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:32:51.000000000 +0200
+++ wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:56:28.000000000 +0200
@@ -773,12 +773,12 @@
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_CONSUME_TIME, value);
 	rt2x00_register_write(rt2x00dev, TXCSR1, reg[0]);
 
-	value = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
+	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
 
-	reg[0] = cpu_to_le32(0x00700400 | value);	/* ARCSR2 */
-	reg[1] = cpu_to_le32(0x00380401 | value);	/* ARCSR3 */
-	reg[2] = cpu_to_le32(0x00150402 | value);	/* ARCSR4 */
-	reg[3] = cpu_to_le32(0x000b8403 | value);	/* ARCSR5 */
+	reg[0] = cpu_to_le32(0x00700400 | preamble);	/* ARCSR2 */
+	reg[1] = cpu_to_le32(0x00380401 | preamble);	/* ARCSR3 */
+	reg[2] = cpu_to_le32(0x00150402 | preamble);	/* ARCSR4 */
+	reg[3] = cpu_to_le32(0x000b8403 | preamble);	/* ARCSR5 */
 
 	rt2x00_register_multiwrite(rt2x00dev, ARCSR2, &reg[0], sizeof(reg));
 }
diff -rU3 wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:34:16.000000000 +0200
+++ wireless-dev-rt2x00-variable/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:56:34.000000000 +0200
@@ -839,12 +839,12 @@
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_CONSUME_TIME, value);
 	rt2x00_register_write(rt2x00dev, TXCSR1, reg[0]);
 
-	value = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
+	preamble = DEVICE_GET_RATE_FIELD(rate, PREAMBLE) ? 8 : 0;
 
-	reg[0] = cpu_to_le32(0x00700400 | value);	/* ARCSR2 */
-	reg[1] = cpu_to_le32(0x00380401 | value);	/* ARCSR3 */
-	reg[2] = cpu_to_le32(0x00150402 | value);	/* ARCSR4 */
-	reg[3] = cpu_to_le32(0x000b8403 | value);	/* ARCSR5 */
+	reg[0] = cpu_to_le32(0x00700400 | preamble);	/* ARCSR2 */
+	reg[1] = cpu_to_le32(0x00380401 | preamble);	/* ARCSR3 */
+	reg[2] = cpu_to_le32(0x00150402 | preamble);	/* ARCSR4 */
+	reg[3] = cpu_to_le32(0x000b8403 | preamble);	/* ARCSR5 */
 
 	rt2x00_register_multiwrite(rt2x00dev, ARCSR2, &reg[0], sizeof(reg));
 }
