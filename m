From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next] tools: hv: Enable network manager for bonding
 scripts on RHEL
Date: Fri,  2 Dec 2016 15:55:38 -0800
Message-ID: <1480722938-23378-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, haiyangz@microsoft.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
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

From: Haiyang Zhang <haiyangz@microsoft.com>

We found network manager is necessary on RHEL to make the synthetic
NIC, VF NIC bonding operations handled automatically. So, enabling
network manager here.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 tools/hv/bondvf.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/hv/bondvf.sh b/tools/hv/bondvf.sh
index 8e96023..4aa5369 100755
--- a/tools/hv/bondvf.sh
+++ b/tools/hv/bondvf.sh
@@ -74,8 +74,8 @@ function create_eth_cfg_redhat {
 	echo DEVICE=$1 >>$fn
 	echo TYPE=Ethernet >>$fn
 	echo BOOTPROTO=none >>$fn
+	echo UUID=`uuidgen` >>$fn
 	echo ONBOOT=yes >>$fn
-	echo NM_CONTROLLED=no >>$fn
 	echo PEERDNS=yes >>$fn
 	echo IPV6INIT=yes >>$fn
 	echo MASTER=$2 >>$fn
@@ -93,8 +93,8 @@ function create_bond_cfg_redhat {
 	echo DEVICE=$1 >>$fn
 	echo TYPE=Bond >>$fn
 	echo BOOTPROTO=dhcp >>$fn
+	echo UUID=`uuidgen` >>$fn
 	echo ONBOOT=yes >>$fn
-	echo NM_CONTROLLED=no >>$fn
 	echo PEERDNS=yes >>$fn
 	echo IPV6INIT=yes >>$fn
 	echo BONDING_MASTER=yes >>$fn
-- 
1.7.4.1
