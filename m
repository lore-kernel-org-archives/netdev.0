From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/12] caif_hsi.h: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 11:37:40 -0700
Message-ID: <40537362e8ba86fa727226ddfeb75c205c63ecaf.1379961014.git.joe@perches.com>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
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
 include/net/caif/caif_hsi.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index 4795e81..097f69c 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -195,6 +195,6 @@ enum ifla_caif_hsi {
 	__IFLA_CAIF_HSI_MAX
 };
 
-extern struct cfhsi_ops *cfhsi_get_ops(void);
+struct cfhsi_ops *cfhsi_get_ops(void);
 
 #endif		/* CAIF_HSI_H_ */
-- 
1.8.1.2.459.gbcd45b4.dirty
