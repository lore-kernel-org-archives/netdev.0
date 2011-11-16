From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/5] bna: Convert MAC_ADDRLEN uses to ETH_ALEN
Date: Wed, 16 Nov 2011 11:38:04 -0800
Message-ID: <8a6f9ad67a3d580565cafb7a44cec0165831c35d.1321472143.git.joe@perches.com>
References: <cover.1321472142.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321472142.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce the number of #defines, use the normal #define from if_ether.h

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/brocade/bna/cna.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
index 1b3e90d..32e8f17 100644
--- a/drivers/net/ethernet/brocade/bna/cna.h
+++ b/drivers/net/ethernet/brocade/bna/cna.h
@@ -43,8 +43,7 @@ extern char bfa_version[];
 
 #pragma pack(1)
 
-#define MAC_ADDRLEN	(6)
-typedef struct mac { u8 mac[MAC_ADDRLEN]; } mac_t;
+typedef struct mac { u8 mac[ETH_ALEN]; } mac_t;
 
 #pragma pack()
 
-- 
1.7.6.405.gc1be0
