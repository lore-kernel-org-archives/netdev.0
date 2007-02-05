From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH 2.6.20] ixgb: Use ARRAY_SIZE macro when appropriate
Date: Mon, 5 Feb 2007 18:59:33 +0200
Message-ID: <20070205165933.GL3896@Ahmed>
References: <20070205165429.GD3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:43213 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932846AbXBEQ7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 11:59:39 -0500
Received: by an-out-0708.google.com with SMTP id b33so1070087ana
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 08:59:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20070205165429.GD3896@Ahmed>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A patch to use ARRAY_SIZE macro already defined in kernel.h.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
---
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index b27442a..26031fe 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -245,7 +245,7 @@ ixgb_validate_option(int *value, struct ixgb_option *opt)
 	return -1;
 }
 
-#define LIST_LEN(l) (sizeof(l) / sizeof(l[0]))
+#define LIST_LEN(l) ARRAY_SIZE(l)
 
 /**
  * ixgb_check_options - Range Checking for Command Line Parameters


-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
