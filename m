From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 09/10] samples/pktgen: Show the results rather than
 just commenting where they are
Date: Tue, 24 Feb 2015 02:33:20 +0000
Message-ID: <1424745200.4443.10.camel@xylophone.i.decadent.org.uk>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:55430 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbbBXCdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 21:33:22 -0500
In-Reply-To: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 samples/pktgen/pktgen.conf-1-1          |    3 +--
 samples/pktgen/pktgen.conf-1-1-flows    |    3 +--
 samples/pktgen/pktgen.conf-1-1-ip6      |    3 +--
 samples/pktgen/pktgen.conf-1-1-ip6-rdos |    3 +--
 samples/pktgen/pktgen.conf-1-1-rdos     |    3 +--
 samples/pktgen/pktgen.conf-1-2          |    3 +--
 samples/pktgen/pktgen.conf-2-1          |    3 +--
 samples/pktgen/pktgen.conf-2-2          |    3 +--
 8 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/samples/pktgen/pktgen.conf-1-1 b/samples/pktgen/pktgen.conf-1-1
index 68eb6385d2fa..fd797216006d 100755
--- a/samples/pktgen/pktgen.conf-1-1
+++ b/samples/pktgen/pktgen.conf-1-1
@@ -56,5 +56,4 @@ PGDEV=/proc/net/pktgen/pgctrl
  trap true INT
  pgset "start" 
  echo "Done"
-
-# Result can be vieved in /proc/net/pktgen/eth1
+ cat /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-1-1-flows b/samples/pktgen/pktgen.conf-1-1-flows
index a1973bc4cabb..f22ae0c3b039 100755
--- a/samples/pktgen/pktgen.conf-1-1-flows
+++ b/samples/pktgen/pktgen.conf-1-1-flows
@@ -64,5 +64,4 @@ PGDEV=/proc/net/pktgen/pgctrl
  trap true INT
  pgset "start" 
  echo "Done"
-
-# Result can be vieved in /proc/net/pktgen/eth1
+ cat /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6 b/samples/pktgen/pktgen.conf-1-1-ip6
index 39cddd36b370..2262f663b3a3 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6
+++ b/samples/pktgen/pktgen.conf-1-1-ip6
@@ -57,5 +57,4 @@ PGDEV=/proc/net/pktgen/pgctrl
  trap true INT
  pgset "start" 
  echo "Done"
-
-# Result can be vieved in /proc/net/pktgen/eth1
+ cat /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6-rdos b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
index e7dbf4845c8f..e13239789e63 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
@@ -60,5 +60,4 @@ PGDEV=/proc/net/pktgen/pgctrl
  trap true INT
  pgset "start" 
  echo "Done"
-
-# Result can be vieved in /proc/net/pktgen/eth1
+ cat /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-1-1-rdos b/samples/pktgen/pktgen.conf-1-1-rdos
index f4c3c4ebf228..066d6d28761e 100755
--- a/samples/pktgen/pktgen.conf-1-1-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-rdos
@@ -61,5 +61,4 @@ PGDEV=/proc/net/pktgen/pgctrl
  trap true INT
  pgset "start" 
  echo "Done"
-
-# Result can be vieved in /proc/net/pktgen/eth1
+ cat /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-1-2 b/samples/pktgen/pktgen.conf-1-2
index 7dcdeab4363b..2924eb0f991c 100755
--- a/samples/pktgen/pktgen.conf-1-2
+++ b/samples/pktgen/pktgen.conf-1-2
@@ -66,5 +66,4 @@ PGDEV=/proc/net/pktgen/pgctrl
  trap true INT
  pgset "start" 
  echo "Done"
-
-# Result can be vieved in /proc/net/pktgen/eth[1,2]
+ cat /proc/net/pktgen/eth1 /proc/net/pktgen/eth2
diff --git a/samples/pktgen/pktgen.conf-2-1 b/samples/pktgen/pktgen.conf-2-1
index 9fee8da739c7..20e2291463e3 100755
--- a/samples/pktgen/pktgen.conf-2-1
+++ b/samples/pktgen/pktgen.conf-2-1
@@ -63,5 +63,4 @@ PGDEV=/proc/net/pktgen/pgctrl
  trap true INT
  pgset "start" 
  echo "Done"
-
-# Result can be vieved in /proc/net/pktgen/eth1
+ cat /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-2-2 b/samples/pktgen/pktgen.conf-2-2
index 29b338cc054d..2476a6e8c29c 100755
--- a/samples/pktgen/pktgen.conf-2-2
+++ b/samples/pktgen/pktgen.conf-2-2
@@ -70,5 +70,4 @@ PGDEV=/proc/net/pktgen/pgctrl
  trap true INT
  pgset "start" 
  echo "Done"
-
-# Result can be vieved in /proc/net/pktgen/eth[1,2]
+ cat /proc/net/pktgen/eth1 /proc/net/pktgen/eth2
-- 
1.7.10.4
