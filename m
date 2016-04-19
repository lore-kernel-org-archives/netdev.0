From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next V3 1/2] ethernet: intel: Add the device ID's
 presented while running on Hyper-V
Date: Tue, 19 Apr 2016 08:49:27 -0700
Message-ID: <1461080968-25235-1-git-send-email-kys@microsoft.com>
References: <1461080945-25194-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, eli@mellanox.com, jackm@mellanox.com,
 yevgenyp@mellanox.com, john.ronciak@intel.com,
 intel-wired-lan@lists.osuosl.org, alexander.duyck@gmail.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1461080945-25194-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Intel SR-IOV cards present different ID when running on Hyper-V.
Add the device IDs presented while running on Hyper-V.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
	V2: No change from V1.
	V3: No change from V2.

 drivers/net/ethernet/intel/ixgbevf/defines.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index 5843458..1306a0d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -33,6 +33,11 @@
 #define IXGBE_DEV_ID_X550_VF		0x1565
 #define IXGBE_DEV_ID_X550EM_X_VF	0x15A8
 
+#define IXGBE_DEV_ID_82599_VF_HV	0x152E
+#define IXGBE_DEV_ID_X540_VF_HV		0x1530
+#define IXGBE_DEV_ID_X550_VF_HV		0x1564
+#define IXGBE_DEV_ID_X550EM_X_VF_HV	0x15A9
+
 #define IXGBE_VF_IRQ_CLEAR_MASK		7
 #define IXGBE_VF_MAX_TX_QUEUES		8
 #define IXGBE_VF_MAX_RX_QUEUES		8
-- 
1.7.4.1
