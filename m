From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] misc/ss: don't imply -a when -A was specified
Date: Fri,  7 Aug 2015 15:31:27 +0200
Message-ID: <1438954287-4413-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53879 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753088AbbHGNb3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2015 09:31:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index bba7009..2f34962 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3669,6 +3669,8 @@ int main(int argc, char *argv[])
 			char *p, *p1;
 			if (!saw_query) {
 				current_filter.dbs = 0;
+				state_filter = state_filter ?
+				               state_filter : SS_CONN;
 				saw_query = 1;
 				do_default = 0;
 			}
-- 
2.1.2
