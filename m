From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 07/26] qlogic, netxen: get rid of a redundant test for NULL
 before call to release_firmware()
Date: Mon, 9 Apr 2012 22:50:31 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204092214360.13925@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since release_firmware() deals gracefully with being passed a NULL
pointer there is no reason to test explicitly before calling the
function.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 718b274..1fb149c 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1261,8 +1261,7 @@ next:
 void
 netxen_release_firmware(struct netxen_adapter *adapter)
 {
-	if (adapter->fw)
-		release_firmware(adapter->fw);
+	release_firmware(adapter->fw);
 	adapter->fw = NULL;
 }
 
-- 
1.7.10


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
