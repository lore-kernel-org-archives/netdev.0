From: Joe Perches <joe@perches.com>
Subject: [PATCH 55/59] net/sctp: Add missing "space"
Date: Mon, 19 Nov 2007 17:53:42 -0800
Message-ID: <1195523627-15389-13-git-send-email-joe@perches.com>
References: 1234567
 <1195523627-15389-1-git-send-email-joe@perches.com>
 <1195523627-15389-2-git-send-email-joe@perches.com>
 <1195523627-15389-3-git-send-email-joe@perches.com>
 <1195523627-15389-4-git-send-email-joe@perches.com>
 <1195523627-15389-5-git-send-email-joe@perches.com>
 <1195523627-15389-6-git-send-email-joe@perches.com>
 <1195523627-15389-7-git-send-email-joe@perches.com>
 <1195523627-15389-8-git-send-email-joe@perches.com>
 <1195523627-15389-9-git-send-email-joe@perches.com>
 <1195523627-15389-10-git-send-email-joe@perches.com>
 <1195523627-15389-11-git-send-email-joe@perches.com>
 <1195523627-15389-12-git-send-email-joe@perches.com>
Cc: Networking Team <netdev@vger.kernel.org>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	lksctp-developers@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2217 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758881AbXKTBx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 20:53:58 -0500
In-Reply-To: <1195523627-15389-12-git-send-email-joe@perches.com>
Message-Id: <c7b79830e5796ae4499e169a357b575320fb0fe0.1195454436.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sctp/sm_statefuns.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 5ebbe80..b8bbb96 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1146,7 +1146,7 @@ sctp_disposition_t sctp_sf_backbeat_8_3(const struct sctp_endpoint *ep,
 	/* Check if the timestamp looks valid.  */
 	if (time_after(hbinfo->sent_at, jiffies) ||
 	    time_after(jiffies, hbinfo->sent_at + max_interval)) {
-		SCTP_DEBUG_PRINTK("%s: HEARTBEAT ACK with invalid timestamp"
+		SCTP_DEBUG_PRINTK("%s: HEARTBEAT ACK with invalid timestamp "
 				  "received for transport: %p\n",
 				   __FUNCTION__, link);
 		return SCTP_DISPOSITION_DISCARD;
-- 
1.5.3.5.652.gf192c

