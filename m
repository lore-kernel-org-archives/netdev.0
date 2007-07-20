From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NET: Add missing entries to family name tables
Date: Fri, 20 Jul 2007 10:53:25 +0100
Message-ID: <20070720095325.23049.72209.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35141 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755421AbXGTJx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 05:53:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing entries to af_family_clock_key_strings[].

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/core/sock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index bd209c4..cfed7d4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -182,7 +182,8 @@ static const char *af_family_clock_key_strings[AF_MAX+1] = {
   "clock-21"       , "clock-AF_SNA"      , "clock-AF_IRDA"     ,
   "clock-AF_PPPOX" , "clock-AF_WANPIPE"  , "clock-AF_LLC"      ,
   "clock-27"       , "clock-28"          , "clock-29"          ,
-  "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_MAX"
+  "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
+  "clock-AF_RXRPC" , "clock-AF_MAX"
 };
 #endif
 

