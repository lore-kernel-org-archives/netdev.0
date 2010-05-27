From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [PATCH net-2.6] be2net: Patch removes redundant while statement in
 loop.
Date: Thu, 27 May 2010 15:02:19 +0530
Message-ID: <20100527093208.GA13740@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:41688 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S933894Ab0E0JcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 05:32:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index aa065c7..54b1427 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1861,7 +1861,7 @@ static int be_setup(struct be_adapter *a
 				goto if_destroy;
 			}
 			vf++;
-		} while (vf < num_vfs);
+		}
 	} else if (!be_physfn(adapter)) {
 		status = be_cmd_mac_addr_query(adapter, mac,
 			MAC_ADDRESS_TYPE_NETWORK, false, adapter->if_handle);
-- 
1.4.0

