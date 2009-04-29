From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH net-next] ixgbe: removing unnecesary
	assignments
Date: Wed, 29 Apr 2009 14:15:27 -0300
Message-ID: <49F88B2F.4000802@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: e1000-devel@lists.sourceforge.net
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

This patch removes some assignment that are not necessary. Since the ret
variable is declared as false during its initialization, it makes no sense to
reassign false to it again.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

---
 drivers/net/ixgbe/ixgbe_main.c |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5020f11..c238677 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2775,8 +2775,6 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 		adapter->num_tx_queues =
 		                      adapter->ring_feature[RING_F_DCB].indices;
 		ret = true;
-	} else {
-		ret = false;
 	}
 
 	return ret;
@@ -2802,8 +2800,6 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 		adapter->num_tx_queues =
 		                      adapter->ring_feature[RING_F_RSS].indices;
 		ret = true;
-	} else {
-		ret = false;
 	}
 
 	return ret;
@@ -2910,8 +2906,6 @@ static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			adapter->tx_ring[i].reg_idx = i;
 		ret = true;
-	} else {
-		ret = false;
 	}
 
 	return ret;
@@ -2986,14 +2980,8 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 					adapter->rx_ring[i].reg_idx = i << 5;
 
 				ret = true;
-			} else {
-				ret = false;
 			}
-		} else {
-			ret = false;
 		}
-	} else {
-		ret = false;
 	}
 
 	return ret;
-- 
1.6.0.2


------------------------------------------------------------------------------
Register Now & Save for Velocity, the Web Performance & Operations 
Conference from O'Reilly Media. Velocity features a full day of 
expert-led, hands-on workshops and two days of sessions from industry 
leaders in dedicated Performance & Operations tracks. Use code vel09scf 
and Save an extra 15% before 5/3. http://p.sf.net/sfu/velocityconf
