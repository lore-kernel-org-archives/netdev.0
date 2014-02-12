From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 06/13] sfc: Remove unused definitions of EF10 user-mode
 DMA descriptors
Date: Wed, 12 Feb 2014 18:59:07 +0000
Message-ID: <52FBC47B.6010203@solarflare.com>
References: <52FBC3C2.7030103@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50951 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbaBLS7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 13:59:11 -0500
In-Reply-To: <52FBC3C2.7030103@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

These DMA descriptor types will only be used by the userland
networking stack.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_regs.h |   61 ----------------------------------
 1 files changed, 0 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10_regs.h b/drivers/net/ethernet/sfc/ef10_regs.h
index 207ac9a..62a55dd 100644
--- a/drivers/net/ethernet/sfc/ef10_regs.h
+++ b/drivers/net/ethernet/sfc/ef10_regs.h
@@ -227,36 +227,6 @@
 #define	ESF_DZ_RX_KER_BUF_ADDR_LBN 0
 #define	ESF_DZ_RX_KER_BUF_ADDR_WIDTH 48
 
-/* RX_USER_DESC */
-#define	ESF_DZ_RX_USR_RESERVED_LBN 62
-#define	ESF_DZ_RX_USR_RESERVED_WIDTH 2
-#define	ESF_DZ_RX_USR_BYTE_CNT_LBN 48
-#define	ESF_DZ_RX_USR_BYTE_CNT_WIDTH 14
-#define	ESF_DZ_RX_USR_BUF_PAGE_SIZE_LBN 44
-#define	ESF_DZ_RX_USR_BUF_PAGE_SIZE_WIDTH 4
-#define	ESE_DZ_USR_BUF_PAGE_SZ_4MB 10
-#define	ESE_DZ_USR_BUF_PAGE_SZ_1MB 8
-#define	ESE_DZ_USR_BUF_PAGE_SZ_64KB 4
-#define	ESE_DZ_USR_BUF_PAGE_SZ_4KB 0
-#define	ESF_DZ_RX_USR_BUF_ID_OFFSET_LBN 0
-#define	ESF_DZ_RX_USR_BUF_ID_OFFSET_WIDTH 44
-#define	ESF_DZ_RX_USR_4KBPS_BUF_ID_LBN 12
-#define	ESF_DZ_RX_USR_4KBPS_BUF_ID_WIDTH 32
-#define	ESF_DZ_RX_USR_64KBPS_BUF_ID_LBN 16
-#define	ESF_DZ_RX_USR_64KBPS_BUF_ID_WIDTH 28
-#define	ESF_DZ_RX_USR_1MBPS_BUF_ID_LBN 20
-#define	ESF_DZ_RX_USR_1MBPS_BUF_ID_WIDTH 24
-#define	ESF_DZ_RX_USR_4MBPS_BUF_ID_LBN 22
-#define	ESF_DZ_RX_USR_4MBPS_BUF_ID_WIDTH 22
-#define	ESF_DZ_RX_USR_4MBPS_BYTE_OFFSET_LBN 0
-#define	ESF_DZ_RX_USR_4MBPS_BYTE_OFFSET_WIDTH 22
-#define	ESF_DZ_RX_USR_1MBPS_BYTE_OFFSET_LBN 0
-#define	ESF_DZ_RX_USR_1MBPS_BYTE_OFFSET_WIDTH 20
-#define	ESF_DZ_RX_USR_64KBPS_BYTE_OFFSET_LBN 0
-#define	ESF_DZ_RX_USR_64KBPS_BYTE_OFFSET_WIDTH 16
-#define	ESF_DZ_RX_USR_4KBPS_BYTE_OFFSET_LBN 0
-#define	ESF_DZ_RX_USR_4KBPS_BYTE_OFFSET_WIDTH 12
-
 /* TX_CSUM_TSTAMP_DESC */
 #define	ESF_DZ_TX_DESC_IS_OPT_LBN 63
 #define	ESF_DZ_TX_DESC_IS_OPT_WIDTH 1
@@ -338,37 +308,6 @@
 #define	ESF_DZ_TX_TSO_TCP_SEQNO_LBN 0
 #define	ESF_DZ_TX_TSO_TCP_SEQNO_WIDTH 32
 
-/* TX_USER_DESC */
-#define	ESF_DZ_TX_USR_TYPE_LBN 63
-#define	ESF_DZ_TX_USR_TYPE_WIDTH 1
-#define	ESF_DZ_TX_USR_CONT_LBN 62
-#define	ESF_DZ_TX_USR_CONT_WIDTH 1
-#define	ESF_DZ_TX_USR_BYTE_CNT_LBN 48
-#define	ESF_DZ_TX_USR_BYTE_CNT_WIDTH 14
-#define	ESF_DZ_TX_USR_BUF_PAGE_SIZE_LBN 44
-#define	ESF_DZ_TX_USR_BUF_PAGE_SIZE_WIDTH 4
-#define	ESE_DZ_USR_BUF_PAGE_SZ_4MB 10
-#define	ESE_DZ_USR_BUF_PAGE_SZ_1MB 8
-#define	ESE_DZ_USR_BUF_PAGE_SZ_64KB 4
-#define	ESE_DZ_USR_BUF_PAGE_SZ_4KB 0
-#define	ESF_DZ_TX_USR_BUF_ID_OFFSET_LBN 0
-#define	ESF_DZ_TX_USR_BUF_ID_OFFSET_WIDTH 44
-#define	ESF_DZ_TX_USR_4KBPS_BUF_ID_LBN 12
-#define	ESF_DZ_TX_USR_4KBPS_BUF_ID_WIDTH 32
-#define	ESF_DZ_TX_USR_64KBPS_BUF_ID_LBN 16
-#define	ESF_DZ_TX_USR_64KBPS_BUF_ID_WIDTH 28
-#define	ESF_DZ_TX_USR_1MBPS_BUF_ID_LBN 20
-#define	ESF_DZ_TX_USR_1MBPS_BUF_ID_WIDTH 24
-#define	ESF_DZ_TX_USR_4MBPS_BUF_ID_LBN 22
-#define	ESF_DZ_TX_USR_4MBPS_BUF_ID_WIDTH 22
-#define	ESF_DZ_TX_USR_4MBPS_BYTE_OFFSET_LBN 0
-#define	ESF_DZ_TX_USR_4MBPS_BYTE_OFFSET_WIDTH 22
-#define	ESF_DZ_TX_USR_1MBPS_BYTE_OFFSET_LBN 0
-#define	ESF_DZ_TX_USR_1MBPS_BYTE_OFFSET_WIDTH 20
-#define	ESF_DZ_TX_USR_64KBPS_BYTE_OFFSET_LBN 0
-#define	ESF_DZ_TX_USR_64KBPS_BYTE_OFFSET_WIDTH 16
-#define	ESF_DZ_TX_USR_4KBPS_BYTE_OFFSET_LBN 0
-#define	ESF_DZ_TX_USR_4KBPS_BYTE_OFFSET_WIDTH 12
 /*************************************************************************/
 
 /* TX_DESC_UPD_REG: Transmit descriptor update register.
