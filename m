From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 09/12] dcbnl: Add support for setapp/getapp to netdev
	dcbnl_rtnl_ops
Date: Fri, 14 Aug 2009 15:44:08 -0700
Message-ID: <20090814224408.1640.15710.stgit@localhost.localdomain>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090814223857.1640.26881.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yi Zou <yi.zou@intel.com>

Adds support of dcbnl setapp/getapp to dcbnl_rtnl_ops in netdev to allow
LLDs to implement their corresponding dcbnl setapp/getapp ops to support
the IEEE 802.1Q DCBX setapp/getapp commands.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/net/dcbnl.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 775cfc8..b36ac7e 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -48,6 +48,8 @@ struct dcbnl_rtnl_ops {
 	void (*setbcncfg)(struct net_device *, int, u32);
 	void (*getbcnrp)(struct net_device *, int, u8 *);
 	void (*setbcnrp)(struct net_device *, int, u8);
+	u8   (*setapp)(struct net_device *, u8, u16, u8);
+	u8   (*getapp)(struct net_device *, u8, u16);
 };
 
 #endif /* __NET_DCBNL_H__ */

