From: Joe Perches <joe@perches.com>
Subject: [PATCH 29/39] include/linux/device.h: Update WARN uses
Date: Sat, 30 Oct 2010 14:08:46 -0700
Message-ID: <778f097342523b769e018bc3171ba28fbe3e131e.1288471898.git.joe@perches.com>
References: <cover.1288471897.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3790 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752417Ab0J3VJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Oct 2010 17:09:44 -0400
In-Reply-To: <cover.1288471897.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macro argument neatening.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/device.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/device.h b/include/linux/device.h
index dd48953..724d1fd 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -744,7 +744,7 @@ do {						     \
  * file/line information and a backtrace.
  */
 #define dev_WARN(dev, format, arg...) \
-	WARN(1, "Device: %s\n" format, dev_driver_string(dev), ## arg);
+	WARN(1, "Device: %s\n" format, dev_driver_string(dev), ##arg);
 
 /* Create alias, so I can be autoloaded. */
 #define MODULE_ALIAS_CHARDEV(major,minor) \
-- 
1.7.3.1.g432b3.dirty

