From: Joe Perches <joe@perches.com>
Subject: [PATCH] drivers: net: misc: Remove unused OOM variables
Date: Mon, 04 Feb 2013 20:22:29 -0800
Message-ID: <1360038149.4849.11.camel@joe-AO722>
References: <51108250.mCy4M9/YF2ueqPWm%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kbuild test robot <fengguang.wu@intel.com>,
	netdev <netdev@vger.kernel.org>, linux-wimax@intel.com,
	wimax@linuxwimax.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:53104 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754761Ab3BEEWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2013 23:22:31 -0500
In-Reply-To: <51108250.mCy4M9/YF2ueqPWm%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commits 9d11bd159
("wimax: Remove unnecessary alloc/OOM messages, alloc cleanups")
and b2adaca92
("ethernet: Remove unnecessary alloc/OOM messages, alloc cleanups")
added a couple of unused variable warnings.

Remove the now unused variables.

Noticed-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c | 1 -
 drivers/net/wimax/i2400m/rx.c                        | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index db50598..4782dcf 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -201,7 +201,6 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 
 	struct netxen_cmd_buffer *cmd_buf_arr;
 	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
 
 	tx_ring = kzalloc(sizeof(struct nx_host_tx_ring), GFP_KERNEL);
 	if (tx_ring == NULL)
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index 8077e6e..0b60295 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -1346,7 +1346,6 @@ EXPORT_SYMBOL(i2400m_unknown_barker);
 int i2400m_rx_setup(struct i2400m *i2400m)
 {
 	int result = 0;
-	struct device *dev = i2400m_dev(i2400m);
 
 	i2400m->rx_reorder = i2400m_rx_reorder_disabled? 0 : 1;
 	if (i2400m->rx_reorder) {
