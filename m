From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 15/27] drivers/net/qlge: fix sparse warnings: make symbols
	static
Date: Mon, 22 Dec 2008 20:17:09 +0100
Message-ID: <20081222191708.11807.35530.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755841AbYLVTRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:17:14 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/qlge/qlge_ethtool.c:100:6: warning: symbol 'ql_update_stats' was not declared. Should it be static?
  drivers/net/qlge/qlge_mpi.c:22:5: warning: symbol 'ql_get_mb_sts' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/qlge/qlge_ethtool.c |    2 +-
 drivers/net/qlge/qlge_mpi.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index b62fbd4..eefb81b 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -97,7 +97,7 @@ exit:
 	return status;
 }
 
-void ql_update_stats(struct ql_adapter *qdev)
+static void ql_update_stats(struct ql_adapter *qdev)
 {
 	u32 i;
 	u64 data;
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 24fe344..fa31891 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -19,7 +19,7 @@ exit:
 	return status;
 }
 
-int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
+static int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	int i, status;
 

