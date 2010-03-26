From: wzt.wzt@gmail.com
Subject: [PATCH] benet: Fix compile warnnings in drivers/net/benet/be_ethtool.c
Date: Fri, 26 Mar 2010 14:12:59 +0800
Message-ID: <20100326061259.GB30341@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-drivers@serverengines.com,
	sathyap@serverengines.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the following warnings:

be_ethtool.c:493: warning: integer constant is too large for 'long' type
be_ethtool.c:493: warning: integer constant is too large for 'long' type

Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>

---
 drivers/net/benet/be_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 9560d48..51e1065 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -490,7 +490,7 @@ be_test_ddr_dma(struct be_adapter *adapter)
 {
 	int ret, i;
 	struct be_dma_mem ddrdma_cmd;
-	u64 pattern[2] = {0x5a5a5a5a5a5a5a5a, 0xa5a5a5a5a5a5a5a5};
+	u64 pattern[2] = {0x5a5a5a5a5a5a5a5aULL, 0xa5a5a5a5a5a5a5a5ULL};
 
 	ddrdma_cmd.size = sizeof(struct be_cmd_req_ddrdma_test);
 	ddrdma_cmd.va = pci_alloc_consistent(adapter->pdev, ddrdma_cmd.size,
-- 
1.6.5.3
