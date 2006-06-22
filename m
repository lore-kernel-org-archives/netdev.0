From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 13/21] e1000: add E1000_BIG_ENDIAN symbol
Date: Wed, 21 Jun 2006 22:20:34 -0700
Message-ID: <20060622052034.25497.81683.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:56328 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932808AbWFVFOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:36 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This adds a private symbol to signify endianess in our driver.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.h    |    2 +-
 drivers/net/e1000/e1000_osdep.h |    3 +++
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 941b47d..376a2ef 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -351,7 +351,7 @@ struct e1000_host_mng_command_info {
     struct e1000_host_mng_command_header command_header;  /* Command Head/Command Result Head has 4 bytes */
     uint8_t command_data[E1000_HI_MAX_MNG_DATA_LENGTH];   /* Command data can length 0..0x658*/
 };
-#ifdef __BIG_ENDIAN
+#ifdef E1000_BIG_ENDIAN
 struct e1000_host_mng_dhcp_cookie{
     uint32_t signature;
     uint16_t vlan_id;
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 048d052..6130a42 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -83,6 +83,9 @@ typedef enum {
 #define DEBUGOUT3 DEBUGOUT2
 #define DEBUGOUT7 DEBUGOUT3
 
+#ifdef __BIG_ENDIAN
+#define E1000_BIG_ENDIAN __BIG_ENDIAN
+#endif
 
 #define E1000_WRITE_REG(a, reg, value) ( \
     writel((value), ((a)->hw_addr + \



--
Auke Kok <auke-jan.h.kok@intel.com>
