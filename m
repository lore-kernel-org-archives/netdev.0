From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/10] adi: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 15:11:30 -0700
Message-ID: <f33671136be3941cc806b03cd3cebfc5af1cc1bb.1379974101.git.joe@perches.com>
References: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/adi/bfin_mac.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.h b/drivers/net/ethernet/adi/bfin_mac.h
index 7a07ee0..6dec86a 100644
--- a/drivers/net/ethernet/adi/bfin_mac.h
+++ b/drivers/net/ethernet/adi/bfin_mac.h
@@ -104,6 +104,6 @@ struct bfin_mac_local {
 #endif
 };
 
-extern int bfin_get_ether_addr(char *addr);
+int bfin_get_ether_addr(char *addr);
 
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
