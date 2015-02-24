From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 05/10] samples/pktgen: Correct comments about the
 thread config
Date: Tue, 24 Feb 2015 02:32:37 +0000
Message-ID: <1424745157.4443.6.camel@xylophone.i.decadent.org.uk>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Rob Jones <rob.jones@codethink.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:55341 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbbBXCcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 21:32:39 -0500
In-Reply-To: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They all claimed to be two CPU examples using eth1, eth2 but
that is only true in one case!

Rob Jones pointed out spelling and grammar errors here, which I've
also corrected.

Cc: Rob Jones <rob.jones@codethink.co.uk>
Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 samples/pktgen/pktgen.conf-1-1          |    2 +-
 samples/pktgen/pktgen.conf-1-1-flows    |    2 +-
 samples/pktgen/pktgen.conf-1-1-ip6      |    2 +-
 samples/pktgen/pktgen.conf-1-1-ip6-rdos |    2 +-
 samples/pktgen/pktgen.conf-1-1-rdos     |    2 +-
 samples/pktgen/pktgen.conf-1-2          |    2 +-
 samples/pktgen/pktgen.conf-2-1          |    3 ++-
 samples/pktgen/pktgen.conf-2-2          |    2 +-
 8 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/samples/pktgen/pktgen.conf-1-1 b/samples/pktgen/pktgen.conf-1-1
index 63b1005551dd..a147ddc8725f 100755
--- a/samples/pktgen/pktgen.conf-1-1
+++ b/samples/pktgen/pktgen.conf-1-1
@@ -18,7 +18,7 @@ function pgset() {
 

 # thread config
-# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+# Each CPU has its own thread. One CPU example. We add eth1.
 
 PGDEV=/proc/net/pktgen/kpktgend_0
   echo "Removing all devices"
diff --git a/samples/pktgen/pktgen.conf-1-1-flows b/samples/pktgen/pktgen.conf-1-1-flows
index a99356236110..90fb3d0e9c6b 100755
--- a/samples/pktgen/pktgen.conf-1-1-flows
+++ b/samples/pktgen/pktgen.conf-1-1-flows
@@ -18,7 +18,7 @@ function pgset() {
 

 # thread config
-# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+# Each CPU has its own thread. One CPU example. We add eth1.
 
 PGDEV=/proc/net/pktgen/kpktgend_0
   echo "Removing all devices"
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6 b/samples/pktgen/pktgen.conf-1-1-ip6
index 23b5f830bca4..958a030d823d 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6
+++ b/samples/pktgen/pktgen.conf-1-1-ip6
@@ -18,7 +18,7 @@ function pgset() {
 

 # thread config
-# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+# Each CPU has its own thread. One CPU example. We add eth1.
 # IPv6. Note increase in minimal packet length
 
 PGDEV=/proc/net/pktgen/kpktgend_0
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6-rdos b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
index 22a8a617603a..159583531d2d 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
@@ -18,7 +18,7 @@ function pgset() {
 

 # thread config
-# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+# Each CPU has its own thread. One CPU example. We add eth1.
 # IPv6. Note increase in minimal packet length
 
 PGDEV=/proc/net/pktgen/kpktgend_0
diff --git a/samples/pktgen/pktgen.conf-1-1-rdos b/samples/pktgen/pktgen.conf-1-1-rdos
index 67684640f540..4e937e2b9d1e 100755
--- a/samples/pktgen/pktgen.conf-1-1-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-rdos
@@ -18,7 +18,7 @@ function pgset() {
 

 # thread config
-# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+# Each CPU has its own thread. One CPU example. We add eth1.
 
 PGDEV=/proc/net/pktgen/kpktgend_0
   echo "Removing all devices"
diff --git a/samples/pktgen/pktgen.conf-1-2 b/samples/pktgen/pktgen.conf-1-2
index 034b9111fe81..659c832c07f9 100755
--- a/samples/pktgen/pktgen.conf-1-2
+++ b/samples/pktgen/pktgen.conf-1-2
@@ -18,7 +18,7 @@ function pgset() {
 

 # thread config
-# One CPU means one thread. One CPU exammple. We add eth1, eth2 respectivly.
+# One CPU means one thread. One CPU example. We add eth1, eth2 respectivly.
 
 PGDEV=/proc/net/pktgen/kpktgend_0
   echo "Removing all devices"
diff --git a/samples/pktgen/pktgen.conf-2-1 b/samples/pktgen/pktgen.conf-2-1
index caa12fc9ad19..c09c22de4dde 100755
--- a/samples/pktgen/pktgen.conf-2-1
+++ b/samples/pktgen/pktgen.conf-2-1
@@ -18,7 +18,8 @@ function pgset() {
 

 # thread config
-# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+# Each CPU has its own thread. Two CPU example. We add eth1 to the first
+# and leave the second idle.
 
 PGDEV=/proc/net/pktgen/kpktgend_0
   echo "Removing all devices"
diff --git a/samples/pktgen/pktgen.conf-2-2 b/samples/pktgen/pktgen.conf-2-2
index f3d28e98a665..4664f16e9fe0 100755
--- a/samples/pktgen/pktgen.conf-2-2
+++ b/samples/pktgen/pktgen.conf-2-2
@@ -18,7 +18,7 @@ function pgset() {
 

 # thread config
-# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+# Each CPU has its own thread. Two CPU example. We add eth1, eth2 respectively.
 
 PGDEV=/proc/net/pktgen/kpktgend_0
   echo "Removing all devices"
-- 
1.7.10.4
