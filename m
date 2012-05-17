From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] etherdevice: fix comments
Date: Thu, 17 May 2012 08:17:28 -0700
Message-ID: <20120517081728.54719129@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53529 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204Ab2EQPRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 11:17:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some minor problems in comments of etherdevice.h
 * Warning is out dated, file hasn't moved or disappeared in many years and
    is unlikely to do so soon.
 * Capitalize Ethernet consistently since it is a proper name
 * Fix descriptive comment of padding
 * Spelling and grammar fix for alignment comment

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
 

--- a/include/linux/etherdevice.h	2012-05-17 07:28:39.911045825 -0700
+++ b/include/linux/etherdevice.h	2012-05-17 08:15:26.448550013 -0700
@@ -18,8 +18,6 @@
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
  *
- *	WARNING: This move may well be temporary. This file will get merged with others RSN.
- *
  */
 #ifndef _LINUX_ETHERDEVICE_H
 #define _LINUX_ETHERDEVICE_H
@@ -159,7 +157,7 @@ static inline void eth_hw_addr_random(st
  * @addr1: Pointer to a six-byte array containing the Ethernet address
  * @addr2: Pointer other six-byte array containing the Ethernet address
  *
- * Compare two ethernet addresses, returns 0 if equal, non-zero otherwise.
+ * Compare two Ethernet addresses, returns 0 if equal, non-zero otherwise.
  * Unlike memcmp(), it doesn't return a value suitable for sorting.
  */
 static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
@@ -176,7 +174,7 @@ static inline unsigned compare_ether_add
  * @addr1: Pointer to a six-byte array containing the Ethernet address
  * @addr2: Pointer other six-byte array containing the Ethernet address
  *
- * Compare two ethernet addresses, returns true if equal
+ * Compare two Ethernet addresses, returns true if equal
  */
 static inline bool ether_addr_equal(const u8 *addr1, const u8 *addr2)
 {
@@ -197,13 +195,13 @@ static inline unsigned long zap_last_2by
  * @addr1: Pointer to an array of 8 bytes
  * @addr2: Pointer to an other array of 8 bytes
  *
- * Compare two ethernet addresses, returns true if equal, false otherwise.
+ * Compare two Ethernet addresses, returns true if equal, false otherwise.
  *
  * The function doesn't need any conditional branches and possibly uses
  * word memory accesses on CPU allowing cheap unaligned memory reads.
- * arrays = { byte1, byte2, byte3, byte4, byte6, byte7, pad1, pad2}
+ * arrays = { byte1, byte2, byte3, byte4, byte5, byte6, pad1, pad2 }
  *
- * Please note that alignment of addr1 & addr2 is only guaranted to be 16 bits.
+ * Please note that alignment of addr1 & addr2 are only guaranteed to be 16 bits.
  */
 
 static inline bool ether_addr_equal_64bits(const u8 addr1[6+2],
@@ -257,7 +255,7 @@ static inline bool is_etherdev_addr(cons
  * @a: Pointer to Ethernet header
  * @b: Pointer to Ethernet header
  *
- * Compare two ethernet headers, returns 0 if equal.
+ * Compare two Ethernet headers, returns 0 if equal.
  * This assumes that the network header (i.e., IP header) is 4-byte
  * aligned OR the platform can handle unaligned access.  This is the
  * case for all packets coming into netif_receive_skb or similar
