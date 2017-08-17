From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: ibm: ibmvnic: constify vio_device_id
Date: Thu, 17 Aug 2017 18:52:54 +0530
Message-ID: <74d0d08fe98bf52e122d027efdcd7f9811309325.1502975929.git.arvind.yadav.cs@gmail.com>
References: <b8393cdf646fae5ccbb64aab482c133fd54a7339.1502975929.git.arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
To: tlfalcon@linux.vnet.ibm.com, benh@kernel.crashing.org,
        jallen@linux.vnet.ibm.com, mpe@ellerman.id.au, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b8393cdf646fae5ccbb64aab482c133fd54a7339.1502975929.git.arvind.yadav.cs@gmail.com>
In-Reply-To: <b8393cdf646fae5ccbb64aab482c133fd54a7339.1502975929.git.arvind.yadav.cs@gmail.com>
References: <b8393cdf646fae5ccbb64aab482c133fd54a7339.1502975929.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vio_device_id are not supposed to change at runtime. All functions
working with vio_device_id provided by <asm/vio.h> work with
const vio_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index a3e6946..d5372b5 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3859,7 +3859,7 @@ static int ibmvnic_resume(struct device *dev)
 	return 0;
 }
 
-static struct vio_device_id ibmvnic_device_table[] = {
+static const struct vio_device_id ibmvnic_device_table[] = {
 	{"network", "IBM,vnic"},
 	{"", "" }
 };
-- 
2.7.4
