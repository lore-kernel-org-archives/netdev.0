From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 38/39] wimax: export linux/wimax.h and linux/wimax/i2400m.h with headers_install
Date: Wed, 26 Nov 2008 14:40:57 -0800
Message-ID: <5f5d6c59cc5dc618552350f21621f58babeeef90.1227691434.git.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org, David Woodhouse <dwmw2@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:44410 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752920AbYKZWl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 17:41:56 -0500
In-Reply-To: <cover.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two files are what user space can use to establish communication
with the WiMAX kernel API and to speak the Intel 2400m Wireless WiMAX
connection's control protocol.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
---
 include/linux/Kbuild       |    2 ++
 include/linux/wimax/Kbuild |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/wimax/Kbuild

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index e531783..89079ff 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -375,3 +375,5 @@ unifdef-y += xattr.h
 unifdef-y += xfrm.h
 
 objhdr-y += version.h
+header-y += wimax.h
+header-y += wimax/
diff --git a/include/linux/wimax/Kbuild b/include/linux/wimax/Kbuild
new file mode 100644
index 0000000..3cb4f26
--- /dev/null
+++ b/include/linux/wimax/Kbuild
@@ -0,0 +1 @@
+header-y += i2400m.h
-- 
1.5.6.5

