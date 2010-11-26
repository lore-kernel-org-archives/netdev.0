From: Stefan Achatz <erazor_de@users.sourceforge.net>
Subject: [PATCH 3/5] HID: roccat: declaring meaning of pack pragma usage in
 driver headers
Date: Fri, 26 Nov 2010 20:57:36 +0100
Message-ID: <1290801456.18750.164.camel__322.824208024208$1290801577$gmane$org@neuromancer>
Reply-To: erazor_de@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@xenotime.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Jiri Kosina <jkosina@suse.cz>,
	Stefan Achatz <erazor_de@users.sourceforge.net>,
	linux-doc@vger.kernel.org, l
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-14.arcor-online.net ([151.189.21.54]:41417 "EHLO
	mail-in-14.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751596Ab0KZT5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 14:57:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using pack pragma to prevent padding bytes in binary data structures
used for hardware communication. Explanation of these pragmas was requested.

Signed-off-by: Stefan Achatz <erazor_de@users.sourceforge.net>
---
 drivers/hid/hid-roccat-kone.h |    3 +++
 drivers/hid/hid-roccat-pyra.h |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/hid/hid-roccat-kone.h b/drivers/hid/hid-roccat-kone.h
index 130d656..11203a7 100644
--- a/drivers/hid/hid-roccat-kone.h
+++ b/drivers/hid/hid-roccat-kone.h
@@ -14,6 +14,9 @@
 
 #include <linux/types.h>
 
+/*
+ * Binary data structures used for hardware communication must have no padding.
+ */
 #pragma pack(push)
 #pragma pack(1)
 
diff --git a/drivers/hid/hid-roccat-pyra.h b/drivers/hid/hid-roccat-pyra.h
index 22f80a8..ac5996e 100644
--- a/drivers/hid/hid-roccat-pyra.h
+++ b/drivers/hid/hid-roccat-pyra.h
@@ -14,6 +14,9 @@
 
 #include <linux/types.h>
 
+/*
+ * Binary data structures used for hardware communication must have no padding.
+ */
 #pragma pack(push)
 #pragma pack(1)
 
-- 
1.7.2.3



