From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 06/15] wimax/i2400m: add missing debug submodule definition
Date: Wed,  4 Nov 2009 13:39:47 -0800
Message-ID: <4dc1bf074e4db5aa281a7b82ceebb24df98922d2.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20707 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932712AbZKDVl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:59 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i2400m driver was missing the definition for the sysfs debug
level, which is declared in debug-levels.h.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 20d574c..7ba00de 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -785,6 +785,7 @@ struct d_level D_LEVEL[] = {
 	D_SUBMODULE_DEFINE(netdev),
 	D_SUBMODULE_DEFINE(rfkill),
 	D_SUBMODULE_DEFINE(rx),
+	D_SUBMODULE_DEFINE(sysfs),
 	D_SUBMODULE_DEFINE(tx),
 };
 size_t D_LEVEL_SIZE = ARRAY_SIZE(D_LEVEL);
-- 
1.6.2.5

