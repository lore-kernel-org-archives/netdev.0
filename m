From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 5/5] doc, man: ip-rule: Remove incorrect statement about rule 0
Date: Fri,  4 Mar 2016 12:52:41 +0100
Message-ID: <1457092361-17603-6-git-send-email-phil@nwl.cc>
References: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44946 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751888AbcCDLxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 06:53:13 -0500
In-Reply-To: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The documentation is wrong here: it is indeed possible to remove policy
rule 0 and recreate it afterwards. Therefore remove these statements.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 doc/ip-cref.tex    | 3 ---
 man/man8/ip-rule.8 | 2 --
 2 files changed, 5 deletions(-)

diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
index 67094c95b3681..242cc266b7acd 100644
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -2049,9 +2049,6 @@ table \verb|local| (ID 255).
 The \verb|local| table is a special routing table containing
 high priority control routes for local and broadcast addresses.
 
-Rule 0 is special. It cannot be deleted or overridden.
-
-
 \item Priority: 32766, Selector: match anything, Action: lookup routing
 table \verb|main| (ID 254).
 The \verb|main| table is the normal routing table containing all non-policy
diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index e9fbb3cf1a62d..1774ae3ee1fbb 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -118,8 +118,6 @@ The
 .B local
 table is a special routing table containing
 high priority control routes for local and broadcast addresses.
-.sp
-Rule 0 is special. It cannot be deleted or overridden.
 
 .TP
 2.
-- 
2.7.2
