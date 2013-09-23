From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/10] broadcom: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 15:11:33 -0700
Message-ID: <a6af78f72e383e65edeeacd85f76a49611700f8d.1379974101.git.joe@perches.com>
References: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
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
 drivers/net/ethernet/broadcom/cnic_if.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 0658b43..ebbfe25 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -353,8 +353,8 @@ struct cnic_ulp_ops {
 	atomic_t ref_count;
 };
 
-extern int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops);
+int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops);
 
-extern int cnic_unregister_driver(int ulp_type);
+int cnic_unregister_driver(int ulp_type);
 
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
