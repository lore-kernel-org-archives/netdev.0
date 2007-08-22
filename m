From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 2/4] ehea: fix module parameter description
Date: Wed, 22 Aug 2007 16:21:24 +0200
Message-ID: <200708221621.25163.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:64333 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762418AbXHVOxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 10:53:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the module parameter description of "use_mcs" to
show correct default value

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
 drivers/net/ehea/ehea_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 22d000f..db57474 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -76,7 +76,7 @@ MODULE_PARM_DESC(rq1_entries, "Number of entries for Receive Queue 1 "
 MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
 		 "[2^x - 1], x = [6..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
-MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 1 ");
+MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 0 ");
 
 static int port_name_cnt = 0;
 static LIST_HEAD(adapter_list);
-- 
1.5.2

