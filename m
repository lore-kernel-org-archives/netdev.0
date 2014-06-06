From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH] amd-xgbe: Remove unnecessary include
Date: Fri, 6 Jun 2014 08:52:19 -0500
Message-ID: <20140606135219.32017.96806.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The include of asm/cputype.h breaks the powerpc build. This
include was accidentally left in from driver debugging and
can be removed.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 36bc86e..002293b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -116,7 +116,6 @@
 
 #include <linux/phy.h>
 #include <linux/clk.h>
-#include <asm/cputype.h>
 
 #include "xgbe.h"
 #include "xgbe-common.h"
