From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH net-next] ixgbe: return error in set_rar when
 index out of range
Date: Tue, 18 May 2010 08:34:48 -0700
Message-ID: <1274196888.8701.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net, kvm@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Return -1 when set_rar index is out of range

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---
 
 drivers/net/ixgbe/ixgbe_common.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c
b/drivers/net/ixgbe/ixgbe_common.c
index 1159d91..77b3cf4 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1188,6 +1188,7 @@ s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32
index, u8 *addr, u32 vmdq,
 		IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
 	} else {
 		hw_dbg(hw, "RAR index %d is out of range.\n", index);
+		return -1;
 	}
 
 	return 0;



------------------------------------------------------------------------------

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
