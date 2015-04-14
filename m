From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/25] fm10k: fix function header comment
Date: Tue, 14 Apr 2015 16:51:04 -0700
Message-ID: <1429055471-401-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62596 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754938AbbDNXvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:25 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The header comment included a miscopy of a C-code line, and also
mis-used Rx FIFO when it clearly meant Tx FIFO

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index 59faf32..e9ecfb4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -326,8 +326,7 @@ static u16 fm10k_mbx_validate_msg_size(struct fm10k_mbx_info *mbx, u16 len)
  *  fm10k_mbx_write_copy - pulls data off of Tx FIFO and places it in mbmem
  *  @mbx: pointer to mailbox
  *
- *  This function will take a section of the Rx FIFO and copy it into the
-		mbx->tail--;
+ *  This function will take a section of the Tx FIFO and copy it into the
  *  mailbox memory.  The offset in mbmem is based on the lower bits of the
  *  tail and len determines the length to copy.
  **/
-- 
1.9.3
