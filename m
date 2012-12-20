From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/3] iproute2: update help info of bridge command
Date: Thu, 20 Dec 2012 22:31:54 +0800
Message-ID: <1356013915-20835-2-git-send-email-amwang@redhat.com>
References: <1356013915-20835-1-git-send-email-amwang@redhat.com>
Cc: bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55282 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203Ab2LTOcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 09:32:07 -0500
In-Reply-To: <1356013915-20835-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 bridge/bridge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/bridge/bridge.c b/bridge/bridge.c
index 1fcd365..1d59a1e 100644
--- a/bridge/bridge.c
+++ b/bridge/bridge.c
@@ -27,7 +27,7 @@ static void usage(void)
 {
 	fprintf(stderr,
 "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
-"where  OBJECT := { fdb |  monitor }\n"
+"where  OBJECT := { fdb |  mdb | monitor }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails]\n" );
 	exit(-1);
 }
-- 
1.7.7.6
