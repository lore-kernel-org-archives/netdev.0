From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] ptp_pch: fix typo in module parameter description
Date: Tue, 26 Mar 2013 14:54:16 +0100
Message-ID: <2eb67bf713f5c8fae6566b040690fa932087da5f.1364305861.git.jbenc@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1890 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932970Ab3CZNyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 09:54:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/ptp/ptp_pch.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 1367655..e85926b 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -725,7 +725,7 @@ module_exit(ptp_pch_exit);
 
 module_param_string(station, pch_param.station, sizeof pch_param.station, 0444);
 MODULE_PARM_DESC(station,
-	 "IEEE 1588 station address to use - column separated hex values");
+	 "IEEE 1588 station address to use - colon separated hex values");
 
 MODULE_AUTHOR("LAPIS SEMICONDUCTOR, <tshimizu818@gmail.com>");
 MODULE_DESCRIPTION("PTP clock using the EG20T timer");
-- 
1.7.6.5
