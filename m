From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/4] s390: Update defconfigs which were missing CONFIG_NET.
Date: Wed, 24 Sep 2014 14:49:20 -0400 (EDT)
Message-ID: <20140924.144920.2295721206202407829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753562AbaIXStW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 14:49:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit df568d8e ("scsi: Use 'depends' with LIBFC instead of
'select'.")  removed what happened to be the only instance of 'select
NET'. Defconfigs that were relying on the select now lack networking
support.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/s390/configs/default_defconfig     | 1 +
 arch/s390/configs/gcov_defconfig        | 1 +
 arch/s390/configs/performance_defconfig | 1 +
 arch/s390/configs/zfcpdump_defconfig    | 1 +
 arch/s390/defconfig                     | 1 +
 5 files changed, 5 insertions(+)

diff --git a/arch/s390/configs/default_defconfig b/arch/s390/configs/default_defconfig
index 3ca1894..9d94fdd 100644
--- a/arch/s390/configs/default_defconfig
+++ b/arch/s390/configs/default_defconfig
@@ -63,6 +63,7 @@ CONFIG_CRASH_DUMP=y
 # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
 CONFIG_BINFMT_MISC=m
 CONFIG_HIBERNATION=y
+CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_PACKET_DIAG=m
 CONFIG_UNIX=y
diff --git a/arch/s390/configs/gcov_defconfig b/arch/s390/configs/gcov_defconfig
index 4830aa6..90f514b 100644
--- a/arch/s390/configs/gcov_defconfig
+++ b/arch/s390/configs/gcov_defconfig
@@ -61,6 +61,7 @@ CONFIG_CRASH_DUMP=y
 # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
 CONFIG_BINFMT_MISC=m
 CONFIG_HIBERNATION=y
+CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_PACKET_DIAG=m
 CONFIG_UNIX=y
diff --git a/arch/s390/configs/performance_defconfig b/arch/s390/configs/performance_defconfig
index 61db449..13559d3 100644
--- a/arch/s390/configs/performance_defconfig
+++ b/arch/s390/configs/performance_defconfig
@@ -59,6 +59,7 @@ CONFIG_CRASH_DUMP=y
 # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
 CONFIG_BINFMT_MISC=m
 CONFIG_HIBERNATION=y
+CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_PACKET_DIAG=m
 CONFIG_UNIX=y
diff --git a/arch/s390/configs/zfcpdump_defconfig b/arch/s390/configs/zfcpdump_defconfig
index 948e0e0..e376789 100644
--- a/arch/s390/configs/zfcpdump_defconfig
+++ b/arch/s390/configs/zfcpdump_defconfig
@@ -23,6 +23,7 @@ CONFIG_CRASH_DUMP=y
 # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
 # CONFIG_SECCOMP is not set
 # CONFIG_IUCV is not set
+CONFIG_NET=y
 CONFIG_ATM=y
 CONFIG_ATM_LANE=y
 CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
diff --git a/arch/s390/defconfig b/arch/s390/defconfig
index 2e56498..fab35a8 100644
--- a/arch/s390/defconfig
+++ b/arch/s390/defconfig
@@ -50,6 +50,7 @@ CONFIG_CMA=y
 CONFIG_CRASH_DUMP=y
 CONFIG_BINFMT_MISC=m
 CONFIG_HIBERNATION=y
+CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_NET_KEY=y
-- 
1.7.11.7
