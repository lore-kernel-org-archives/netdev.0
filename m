From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 04/10] samples/pktgen: Delete unused function pg()
Date: Tue, 24 Feb 2015 02:32:17 +0000
Message-ID: <1424745137.4443.5.camel@xylophone.i.decadent.org.uk>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:55321 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601AbbBXCcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 21:32:20 -0500
In-Reply-To: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is not used and wouldn't do anything useful as
pktgen does not have an 'inject' command.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 samples/pktgen/pktgen.conf-1-1          |    5 -----
 samples/pktgen/pktgen.conf-1-1-flows    |    5 -----
 samples/pktgen/pktgen.conf-1-1-ip6      |    5 -----
 samples/pktgen/pktgen.conf-1-1-ip6-rdos |    5 -----
 samples/pktgen/pktgen.conf-1-1-rdos     |    5 -----
 samples/pktgen/pktgen.conf-1-2          |    5 -----
 samples/pktgen/pktgen.conf-2-1          |    5 -----
 samples/pktgen/pktgen.conf-2-2          |    5 -----
 8 files changed, 40 deletions(-)

diff --git a/samples/pktgen/pktgen.conf-1-1 b/samples/pktgen/pktgen.conf-1-1
index fb2a1e108690..63b1005551dd 100755
--- a/samples/pktgen/pktgen.conf-1-1
+++ b/samples/pktgen/pktgen.conf-1-1
@@ -14,11 +14,6 @@ function pgset() {
     fi
 }
 
-function pg() {
-    echo inject > $PGDEV
-    cat $PGDEV
-}
-
 # Config Start Here -----------------------------------------------------------
 

diff --git a/samples/pktgen/pktgen.conf-1-1-flows b/samples/pktgen/pktgen.conf-1-1-flows
index 634a860a745c..a99356236110 100755
--- a/samples/pktgen/pktgen.conf-1-1-flows
+++ b/samples/pktgen/pktgen.conf-1-1-flows
@@ -14,11 +14,6 @@ function pgset() {
     fi
 }
 
-function pg() {
-    echo inject > $PGDEV
-    cat $PGDEV
-}
-
 # Config Start Here -----------------------------------------------------------
 

diff --git a/samples/pktgen/pktgen.conf-1-1-ip6 b/samples/pktgen/pktgen.conf-1-1-ip6
index 05a59fea3b49..23b5f830bca4 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6
+++ b/samples/pktgen/pktgen.conf-1-1-ip6
@@ -14,11 +14,6 @@ function pgset() {
     fi
 }
 
-function pg() {
-    echo inject > $PGDEV
-    cat $PGDEV
-}
-
 # Config Start Here -----------------------------------------------------------
 

diff --git a/samples/pktgen/pktgen.conf-1-1-ip6-rdos b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
index 15bf3fb724a2..22a8a617603a 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
@@ -14,11 +14,6 @@ function pgset() {
     fi
 }
 
-function pg() {
-    echo inject > $PGDEV
-    cat $PGDEV
-}
-
 # Config Start Here -----------------------------------------------------------
 

diff --git a/samples/pktgen/pktgen.conf-1-1-rdos b/samples/pktgen/pktgen.conf-1-1-rdos
index d170b5374ae2..67684640f540 100755
--- a/samples/pktgen/pktgen.conf-1-1-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-rdos
@@ -14,11 +14,6 @@ function pgset() {
     fi
 }
 
-function pg() {
-    echo inject > $PGDEV
-    cat $PGDEV
-}
-
 # Config Start Here -----------------------------------------------------------
 

diff --git a/samples/pktgen/pktgen.conf-1-2 b/samples/pktgen/pktgen.conf-1-2
index aab32737bf18..034b9111fe81 100755
--- a/samples/pktgen/pktgen.conf-1-2
+++ b/samples/pktgen/pktgen.conf-1-2
@@ -14,11 +14,6 @@ function pgset() {
     fi
 }
 
-function pg() {
-    echo inject > $PGDEV
-    cat $PGDEV
-}
-
 # Config Start Here -----------------------------------------------------------
 

diff --git a/samples/pktgen/pktgen.conf-2-1 b/samples/pktgen/pktgen.conf-2-1
index 375bc1d2af53..caa12fc9ad19 100755
--- a/samples/pktgen/pktgen.conf-2-1
+++ b/samples/pktgen/pktgen.conf-2-1
@@ -14,11 +14,6 @@ function pgset() {
     fi
 }
 
-function pg() {
-    echo inject > $PGDEV
-    cat $PGDEV
-}
-
 # Config Start Here -----------------------------------------------------------
 

diff --git a/samples/pktgen/pktgen.conf-2-2 b/samples/pktgen/pktgen.conf-2-2
index de800d1d8fbe..f3d28e98a665 100755
--- a/samples/pktgen/pktgen.conf-2-2
+++ b/samples/pktgen/pktgen.conf-2-2
@@ -14,11 +14,6 @@ function pgset() {
     fi
 }
 
-function pg() {
-    echo inject > $PGDEV
-    cat $PGDEV
-}
-
 # Config Start Here -----------------------------------------------------------
 

-- 
1.7.10.4
