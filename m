From: Michal Suchanek <msuchanek@suse.de>
Subject: [PATCH] ibmvnic: Fix unused variable warning
Date: Wed,  9 Aug 2017 13:16:02 +0200
Message-ID: <20170809111602.12170-1-msuchanek@suse.de>
Cc: Michal Suchanek <msuchanek@suse.de>
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes: a248878d7a1d ("ibmvnic: Check for transport event on driver resume")

Signed-off-by: Michal Suchanek <msuchanek@suse.de>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 99576ba4187f..09c20d3b1b79 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3948,7 +3948,6 @@ static int ibmvnic_resume(struct device *dev)
 {
 	struct net_device *netdev = dev_get_drvdata(dev);
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
-	int i;
 
 	if (adapter->state != VNIC_OPEN)
 		return 0;
-- 
2.10.2
