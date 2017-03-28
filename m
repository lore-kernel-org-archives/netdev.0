From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/4] ip: link: macvlan: Add newline to help output
Date: Tue, 28 Mar 2017 23:19:37 +0200
Message-ID: <20170328211939.17922-3-phil@nwl.cc>
References: <20170328211939.17922-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60503 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752931AbdC1VT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 17:19:58 -0400
In-Reply-To: <20170328211939.17922-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A newline between synopsis and variable definition looks nice and is
consistent with others.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink_macvlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
index b9a146f271186..662eb6ff9507c 100644
--- a/ip/iplink_macvlan.c
+++ b/ip/iplink_macvlan.c
@@ -31,6 +31,7 @@ static void print_explain(struct link_util *lu, FILE *f)
 {
 	fprintf(f,
 		"Usage: ... %s mode MODE [flag MODE_FLAG] MODE_OPTS\n"
+		"\n"
 		"MODE: private | vepa | bridge | passthru | source\n"
 		"MODE_FLAG: null | nopromisc\n"
 		"MODE_OPTS: for mode \"source\":\n"
-- 
2.11.0
