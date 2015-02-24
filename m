From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 08/10] samples/pktgen: Trap SIGINT
Date: Tue, 24 Feb 2015 02:33:08 +0000
Message-ID: <1424745188.4443.9.camel@xylophone.i.decadent.org.uk>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:55412 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbbBXCdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 21:33:13 -0500
In-Reply-To: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise ^C stops the script, not just pktgen.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 samples/pktgen/pktgen.conf-1-1          |    1 +
 samples/pktgen/pktgen.conf-1-1-flows    |    1 +
 samples/pktgen/pktgen.conf-1-1-ip6      |    1 +
 samples/pktgen/pktgen.conf-1-1-ip6-rdos |    1 +
 samples/pktgen/pktgen.conf-1-1-rdos     |    1 +
 samples/pktgen/pktgen.conf-1-2          |    1 +
 samples/pktgen/pktgen.conf-2-1          |    1 +
 samples/pktgen/pktgen.conf-2-2          |    1 +
 8 files changed, 8 insertions(+)

diff --git a/samples/pktgen/pktgen.conf-1-1 b/samples/pktgen/pktgen.conf-1-1
index 4679803f6d9e..68eb6385d2fa 100755
--- a/samples/pktgen/pktgen.conf-1-1
+++ b/samples/pktgen/pktgen.conf-1-1
@@ -53,6 +53,7 @@ PGDEV=/proc/net/pktgen/eth1
 PGDEV=/proc/net/pktgen/pgctrl
 
  echo "Running... ctrl^C to stop"
+ trap true INT
  pgset "start" 
  echo "Done"
 
diff --git a/samples/pktgen/pktgen.conf-1-1-flows b/samples/pktgen/pktgen.conf-1-1-flows
index 34703639593f..a1973bc4cabb 100755
--- a/samples/pktgen/pktgen.conf-1-1-flows
+++ b/samples/pktgen/pktgen.conf-1-1-flows
@@ -61,6 +61,7 @@ PGDEV=/proc/net/pktgen/eth1
 PGDEV=/proc/net/pktgen/pgctrl
 
  echo "Running... ctrl^C to stop"
+ trap true INT
  pgset "start" 
  echo "Done"
 
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6 b/samples/pktgen/pktgen.conf-1-1-ip6
index ab4323df3c05..39cddd36b370 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6
+++ b/samples/pktgen/pktgen.conf-1-1-ip6
@@ -54,6 +54,7 @@ PGDEV=/proc/net/pktgen/eth1
 PGDEV=/proc/net/pktgen/pgctrl
 
  echo "Running... ctrl^C to stop"
+ trap true INT
  pgset "start" 
  echo "Done"
 
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6-rdos b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
index 2d3298c53079..e7dbf4845c8f 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
@@ -57,6 +57,7 @@ PGDEV=/proc/net/pktgen/eth1
 PGDEV=/proc/net/pktgen/pgctrl
 
  echo "Running... ctrl^C to stop"
+ trap true INT
  pgset "start" 
  echo "Done"
 
diff --git a/samples/pktgen/pktgen.conf-1-1-rdos b/samples/pktgen/pktgen.conf-1-1-rdos
index 6a8bd27729ff..f4c3c4ebf228 100755
--- a/samples/pktgen/pktgen.conf-1-1-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-rdos
@@ -58,6 +58,7 @@ PGDEV=/proc/net/pktgen/eth1
 PGDEV=/proc/net/pktgen/pgctrl
 
  echo "Running... ctrl^C to stop"
+ trap true INT
  pgset "start" 
  echo "Done"
 
diff --git a/samples/pktgen/pktgen.conf-1-2 b/samples/pktgen/pktgen.conf-1-2
index 98aaa87486d9..7dcdeab4363b 100755
--- a/samples/pktgen/pktgen.conf-1-2
+++ b/samples/pktgen/pktgen.conf-1-2
@@ -63,6 +63,7 @@ PGDEV=/proc/net/pktgen/eth2
 PGDEV=/proc/net/pktgen/pgctrl
 
  echo "Running... ctrl^C to stop"
+ trap true INT
  pgset "start" 
  echo "Done"
 
diff --git a/samples/pktgen/pktgen.conf-2-1 b/samples/pktgen/pktgen.conf-2-1
index 8b6311e8cb96..9fee8da739c7 100755
--- a/samples/pktgen/pktgen.conf-2-1
+++ b/samples/pktgen/pktgen.conf-2-1
@@ -60,6 +60,7 @@ PGDEV=/proc/net/pktgen/eth1
 PGDEV=/proc/net/pktgen/pgctrl
 
  echo "Running... ctrl^C to stop"
+ trap true INT
  pgset "start" 
  echo "Done"
 
diff --git a/samples/pktgen/pktgen.conf-2-2 b/samples/pktgen/pktgen.conf-2-2
index e59e0d2ee8b7..29b338cc054d 100755
--- a/samples/pktgen/pktgen.conf-2-2
+++ b/samples/pktgen/pktgen.conf-2-2
@@ -67,6 +67,7 @@ PGDEV=/proc/net/pktgen/eth2
 PGDEV=/proc/net/pktgen/pgctrl
 
  echo "Running... ctrl^C to stop"
+ trap true INT
  pgset "start" 
  echo "Done"
 
-- 
1.7.10.4
