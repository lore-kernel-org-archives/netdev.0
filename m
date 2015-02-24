From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 07/10] samples/pktgen: Use bash as interpreter
Date: Tue, 24 Feb 2015 02:32:59 +0000
Message-ID: <1424745179.4443.8.camel@xylophone.i.decadent.org.uk>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:55392 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbbBXCdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 21:33:01 -0500
In-Reply-To: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These scripts use the non-POSIX 'function' and 'local' keywords so
they won't work with every /bin/sh.  We could drop 'function' as it is
a no-op, but 'local' makes for cleaner scripts.  Require use of bash.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 samples/pktgen/pktgen.conf-1-1          |    2 +-
 samples/pktgen/pktgen.conf-1-1-flows    |    2 +-
 samples/pktgen/pktgen.conf-1-1-ip6      |    2 +-
 samples/pktgen/pktgen.conf-1-1-ip6-rdos |    2 +-
 samples/pktgen/pktgen.conf-1-1-rdos     |    2 +-
 samples/pktgen/pktgen.conf-1-2          |    2 +-
 samples/pktgen/pktgen.conf-2-1          |    2 +-
 samples/pktgen/pktgen.conf-2-2          |    2 +-
 8 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/samples/pktgen/pktgen.conf-1-1 b/samples/pktgen/pktgen.conf-1-1
index 10c8f15ba0ab..4679803f6d9e 100755
--- a/samples/pktgen/pktgen.conf-1-1
+++ b/samples/pktgen/pktgen.conf-1-1
@@ -1,4 +1,4 @@
-#! /bin/sh
+#!/bin/bash
 
 #modprobe pktgen
 
diff --git a/samples/pktgen/pktgen.conf-1-1-flows b/samples/pktgen/pktgen.conf-1-1-flows
index 033cac87a215..34703639593f 100755
--- a/samples/pktgen/pktgen.conf-1-1-flows
+++ b/samples/pktgen/pktgen.conf-1-1-flows
@@ -1,4 +1,4 @@
-#! /bin/sh
+#!/bin/bash
 
 #modprobe pktgen
 
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6 b/samples/pktgen/pktgen.conf-1-1-ip6
index 3a8a5dc5fa17..ab4323df3c05 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6
+++ b/samples/pktgen/pktgen.conf-1-1-ip6
@@ -1,4 +1,4 @@
-#! /bin/sh
+#!/bin/bash
 
 #modprobe pktgen
 
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6-rdos b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
index 6420a2a37158..2d3298c53079 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
@@ -1,4 +1,4 @@
-#! /bin/sh
+#!/bin/bash
 
 #modprobe pktgen
 
diff --git a/samples/pktgen/pktgen.conf-1-1-rdos b/samples/pktgen/pktgen.conf-1-1-rdos
index adce265d0be4..6a8bd27729ff 100755
--- a/samples/pktgen/pktgen.conf-1-1-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-rdos
@@ -1,4 +1,4 @@
-#! /bin/sh
+#!/bin/bash
 
 #modprobe pktgen
 
diff --git a/samples/pktgen/pktgen.conf-1-2 b/samples/pktgen/pktgen.conf-1-2
index 613e0ba6e963..98aaa87486d9 100755
--- a/samples/pktgen/pktgen.conf-1-2
+++ b/samples/pktgen/pktgen.conf-1-2
@@ -1,4 +1,4 @@
-#! /bin/sh
+#!/bin/bash
 
 #modprobe pktgen
 
diff --git a/samples/pktgen/pktgen.conf-2-1 b/samples/pktgen/pktgen.conf-2-1
index cd4c984098ca..8b6311e8cb96 100755
--- a/samples/pktgen/pktgen.conf-2-1
+++ b/samples/pktgen/pktgen.conf-2-1
@@ -1,4 +1,4 @@
-#! /bin/sh
+#!/bin/bash
 
 #modprobe pktgen
 
diff --git a/samples/pktgen/pktgen.conf-2-2 b/samples/pktgen/pktgen.conf-2-2
index 4037dedbfa01..e59e0d2ee8b7 100755
--- a/samples/pktgen/pktgen.conf-2-2
+++ b/samples/pktgen/pktgen.conf-2-2
@@ -1,4 +1,4 @@
-#! /bin/sh
+#!/bin/bash
 
 #modprobe pktgen
 
-- 
1.7.10.4
