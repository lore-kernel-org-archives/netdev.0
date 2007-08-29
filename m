From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 09/12] export reciprocal_value for modules
Date: Wed, 29 Aug 2007 12:58:18 -0700
Message-ID: <20070829195843.128494688@linux-foundation.org>
References: <20070829193922.078561651@linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59896 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755216AbXH2UBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 16:01:50 -0400
Content-Disposition: inline; filename=reciprocal_export.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Need this in later sky2 code.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/lib/reciprocal_div.c	2007-06-25 09:03:23.000000000 -0700
+++ b/lib/reciprocal_div.c	2007-08-29 11:30:38.000000000 -0700
@@ -1,5 +1,6 @@
 #include <asm/div64.h>
 #include <linux/reciprocal_div.h>
+#include <linux/module.h>
 
 u32 reciprocal_value(u32 k)
 {
@@ -7,3 +8,4 @@ u32 reciprocal_value(u32 k)
 	do_div(val, k);
 	return (u32)val;
 }
+EXPORT_SYMBOL(reciprocal_value);

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

