From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 38/39] wimax: export linux/wimax.h and linux/wimax-i2400m.h with headers_install
Date: Mon, 24 Nov 2008 13:51:01 -0800
Message-ID: <e6e0afbf9b1b8404a1e78364fe7a859f4d3319d7.1227562829.git.inaky@linux.intel.com>
References: <cover.1227562829.git.inaky@linux.intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:57411 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753533AbYKXVvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 16:51:53 -0500
In-Reply-To: <cover.1227562829.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two files are what user space can use to establish communication
with the WiMAX kernel API and to speak the Intel 2400m Wireless WiMAX
connection's control protocol.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
---
 include/linux/Kbuild |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index e531783..e662605 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -375,3 +375,5 @@ unifdef-y += xattr.h
 unifdef-y += xfrm.h
 
 objhdr-y += version.h
+header-y += wimax.h
+header-y += wimax-i2400m.h
-- 
1.5.6.5

