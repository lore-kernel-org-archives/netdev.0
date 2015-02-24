From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 06/10] samples/pktgen: Remove setting of obsolete
 max_before_softirq parameter
Date: Tue, 24 Feb 2015 02:32:48 +0000
Message-ID: <1424745168.4443.7.camel@xylophone.i.decadent.org.uk>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:55366 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbbBXCcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 21:32:50 -0500
In-Reply-To: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 samples/pktgen/pktgen.conf-1-1          |    2 --
 samples/pktgen/pktgen.conf-1-1-flows    |    2 --
 samples/pktgen/pktgen.conf-1-1-ip6      |    2 --
 samples/pktgen/pktgen.conf-1-1-ip6-rdos |    2 --
 samples/pktgen/pktgen.conf-1-1-rdos     |    2 --
 samples/pktgen/pktgen.conf-1-2          |    2 --
 samples/pktgen/pktgen.conf-2-1          |    2 --
 samples/pktgen/pktgen.conf-2-2          |    4 ----
 8 files changed, 18 deletions(-)

diff --git a/samples/pktgen/pktgen.conf-1-1 b/samples/pktgen/pktgen.conf-1-1
index a147ddc8725f..10c8f15ba0ab 100755
--- a/samples/pktgen/pktgen.conf-1-1
+++ b/samples/pktgen/pktgen.conf-1-1
@@ -25,8 +25,6 @@ PGDEV=/proc/net/pktgen/kpktgend_0
  pgset "rem_device_all" 
   echo "Adding eth1"
  pgset "add_device eth1" 
-  echo "Setting max_before_softirq 10000"
- pgset "max_before_softirq 10000"
 

 # device config
diff --git a/samples/pktgen/pktgen.conf-1-1-flows b/samples/pktgen/pktgen.conf-1-1-flows
index 90fb3d0e9c6b..033cac87a215 100755
--- a/samples/pktgen/pktgen.conf-1-1-flows
+++ b/samples/pktgen/pktgen.conf-1-1-flows
@@ -25,8 +25,6 @@ PGDEV=/proc/net/pktgen/kpktgend_0
  pgset "rem_device_all" 
   echo "Adding eth1"
  pgset "add_device eth1" 
-  echo "Setting max_before_softirq 10000"
- pgset "max_before_softirq 10000"
 

 # device config
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6 b/samples/pktgen/pktgen.conf-1-1-ip6
index 958a030d823d..3a8a5dc5fa17 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6
+++ b/samples/pktgen/pktgen.conf-1-1-ip6
@@ -26,8 +26,6 @@ PGDEV=/proc/net/pktgen/kpktgend_0
  pgset "rem_device_all" 
   echo "Adding eth1"
  pgset "add_device eth1" 
-  echo "Setting max_before_softirq 10000"
- pgset "max_before_softirq 10000"
 

 # device config
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6-rdos b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
index 159583531d2d..6420a2a37158 100755
--- a/samples/pktgen/pktgen.conf-1-1-ip6-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
@@ -26,8 +26,6 @@ PGDEV=/proc/net/pktgen/kpktgend_0
  pgset "rem_device_all" 
   echo "Adding eth1"
  pgset "add_device eth1" 
-  echo "Setting max_before_softirq 10000"
- pgset "max_before_softirq 10000"
 

 # device config
diff --git a/samples/pktgen/pktgen.conf-1-1-rdos b/samples/pktgen/pktgen.conf-1-1-rdos
index 4e937e2b9d1e..adce265d0be4 100755
--- a/samples/pktgen/pktgen.conf-1-1-rdos
+++ b/samples/pktgen/pktgen.conf-1-1-rdos
@@ -25,8 +25,6 @@ PGDEV=/proc/net/pktgen/kpktgend_0
  pgset "rem_device_all" 
   echo "Adding eth1"
  pgset "add_device eth1" 
-  echo "Setting max_before_softirq 10000"
- pgset "max_before_softirq 10000"
 

 # device config
diff --git a/samples/pktgen/pktgen.conf-1-2 b/samples/pktgen/pktgen.conf-1-2
index 659c832c07f9..613e0ba6e963 100755
--- a/samples/pktgen/pktgen.conf-1-2
+++ b/samples/pktgen/pktgen.conf-1-2
@@ -27,8 +27,6 @@ PGDEV=/proc/net/pktgen/kpktgend_0
  pgset "add_device eth1" 
   echo "Adding eth2"
  pgset "add_device eth2" 
-  echo "Setting max_before_softirq 10000"
- pgset "max_before_softirq 10000"
 

 # device config
diff --git a/samples/pktgen/pktgen.conf-2-1 b/samples/pktgen/pktgen.conf-2-1
index c09c22de4dde..cd4c984098ca 100755
--- a/samples/pktgen/pktgen.conf-2-1
+++ b/samples/pktgen/pktgen.conf-2-1
@@ -26,8 +26,6 @@ PGDEV=/proc/net/pktgen/kpktgend_0
  pgset "rem_device_all" 
   echo "Adding eth1"
  pgset "add_device eth1" 
-  echo "Setting max_before_softirq 10000"
- pgset "max_before_softirq 10000"
 
 # We need to remove old config since we dont use this thread. We can only
 # one NIC on one CPU due to affinity reasons.
diff --git a/samples/pktgen/pktgen.conf-2-2 b/samples/pktgen/pktgen.conf-2-2
index 4664f16e9fe0..4037dedbfa01 100755
--- a/samples/pktgen/pktgen.conf-2-2
+++ b/samples/pktgen/pktgen.conf-2-2
@@ -25,16 +25,12 @@ PGDEV=/proc/net/pktgen/kpktgend_0
  pgset "rem_device_all" 
   echo "Adding eth1"
  pgset "add_device eth1" 
-  echo "Setting max_before_softirq 10000"
- pgset "max_before_softirq 10000"
 
 PGDEV=/proc/net/pktgen/kpktgend_1
   echo "Removing all devices"
  pgset "rem_device_all" 
   echo "Adding eth2"
  pgset "add_device eth2" 
-  echo "Setting max_before_softirq 10000"
- pgset "max_before_softirq 10000"
 

 # device config
-- 
1.7.10.4
