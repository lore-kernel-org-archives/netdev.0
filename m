From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: enable msi-x for quad-gig boards
Date: Wed, 20 Aug 2008 13:52:48 -0700
Message-ID: <1219265568-28298-1-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:47491 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753295AbYHTUwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 16:52:49 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NX3031 firmware now supports MSI-X interrupts on Quad GbE boards.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 32bb47a..59d6521 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -241,7 +241,7 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P3_REF_QG:
 	case NETXEN_BRDTYPE_P3_4_GB:
 	case NETXEN_BRDTYPE_P3_4_GB_MM:
-		adapter->msix_supported = 0;
+		adapter->msix_supported = !!use_msi_x;
 		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
 		break;
 
-- 
1.5.4.3

