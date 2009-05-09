From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 3/4] netxen: disable msi-x for NC512m adapter
Date: Sat,  9 May 2009 01:02:29 -0700
Message-ID: <1241856150-4488-3-git-send-email-dhananjay@netxen.com>
References: <1241856150-4488-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:48110 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751167AbZEIICa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 May 2009 04:02:30 -0400
In-Reply-To: <1241856150-4488-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This board doesn't suppot msi-x well due to msi-x table
mapping (hardware) issue.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index c61c1d1..86ca081 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -292,7 +292,6 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 		switch (adapter->ahw.board_type) {
 		case NETXEN_BRDTYPE_P2_SB31_10G:
 		case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
-		case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
 			adapter->msix_supported = !!use_msi_x;
 			adapter->rss_supported = !!use_msi_x;
 			break;
-- 
1.6.0.2

