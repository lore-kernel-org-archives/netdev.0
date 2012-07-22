From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Sun, 22 Jul 2012 12:37:33 -0700 (PDT)
Message-ID: <20120722.123733.1898891964192153293.davem@davemloft.net>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<20120722.122405.1220712908232591030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430Ab2GVThe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 15:37:34 -0400
In-Reply-To: <20120722.122405.1220712908232591030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 22 Jul 2012 12:24:05 -0700 (PDT)

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sat, 21 Jul 2012 16:08:49 -0700
> 
>> This series contains updates to ixgbe and ixgbevf.
>> 
>> The following are changes since commit 186e868786f97c8026f0a81400b451ace306b3a4:
>>   forcedeth: spin_unlock_irq in interrupt handler fix
>> and are available in the git repository at:
>>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
> 
> Pulled, thanks Jeff.

Can you guys actually build test this stuff?

====================
[PATCH] ixgbe: Fix build with PCI_IOV enabled.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 47b2ce7..4fea871 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -236,7 +236,7 @@ void ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 	if (ixgbe_vfs_are_assigned(adapter)) {
 		e_dev_warn("Unloading driver while VFs are assigned - VFs will not be deallocated\n");
 		return;
-
+	}
 	/* disable iov and allow time for transactions to clear */
 	pci_disable_sriov(adapter->pdev);
 #endif
-- 
1.7.10.4
