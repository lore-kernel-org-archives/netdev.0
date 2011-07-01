From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Subject: [PATCH] net: rds: fix const array syntax
Date: Fri,  1 Jul 2011 17:50:35 -0500
Message-ID: <1309560635-17514-1-git-send-email-Gregory.Dietsche@cuw.edu>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, kernel-janitors@vger.kernel.org,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>
To: andy.grover@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta21.charter.net ([216.33.127.81]:51392 "EHLO
	mta21.charter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756640Ab1GAWwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 18:52:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct the syntax so that both array and pointer are const.

Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>
---
 net/rds/tcp_stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/tcp_stats.c b/net/rds/tcp_stats.c
index d5898d0..f8a7954 100644
--- a/net/rds/tcp_stats.c
+++ b/net/rds/tcp_stats.c
@@ -40,7 +40,7 @@
 DEFINE_PER_CPU(struct rds_tcp_statistics, rds_tcp_stats)
 	____cacheline_aligned;
 
-static const char const *rds_tcp_stat_names[] = {
+static const char * const rds_tcp_stat_names[] = {
 	"tcp_data_ready_calls",
 	"tcp_write_space_calls",
 	"tcp_sndbuf_full",
-- 
1.7.2.5

