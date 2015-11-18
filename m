From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/2] bridge.8: document fdb replace command
Date: Wed, 18 Nov 2015 12:46:42 +0100
Message-ID: <1447847203-7462-2-git-send-email-phil@nwl.cc>
References: <1447847203-7462-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:37177 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbbKRLq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 06:46:57 -0500
In-Reply-To: <1447847203-7462-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Despite commit 45a82e5 ("iproute vxlan add support for fdb replace
command"), the 'fdb replace' command was not mentioned in bridge.8.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/bridge.8 | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 222a438..3c5bc47 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -50,7 +50,7 @@ bridge \- show / manipulate bridge addresses and devices
 .IR DEV " ]"
 
 .ti -8
-.BR "bridge fdb" " { " add " | " append " | " del " } "
+.BR "bridge fdb" " { " add " | " append " | " del " | " replace " } "
 .I LLADDR
 .B  dev
 .IR DEV " { "
@@ -407,6 +407,13 @@ This command removes an existing fdb entry.
 The arguments are the same as with
 .BR "bridge fdb add" ,
 
+.SS bridge fdb replace - replace a forwarding database entry
+If no matching entry is found, a new one will be created instead.
+
+.PP
+The arguments are the same as with
+.BR "bridge fdb add" ,
+
 .SS bridge fdb show - list forwarding entries.
 
 This command displays the current forwarding table.
-- 
2.5.0
