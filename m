From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/8] wireless: use ARRAY_SIZE()
Date: Thu, 08 Mar 2007 12:52:18 -0800
Message-ID: <20070308205305.873238702@linux-foundation.org>
References: <20070308205214.580772044@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35777 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933315AbXCHUyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 15:54:40 -0500
Content-Disposition: inline; filename=wireless-array-size
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use ARRAY_SIZE() macro now.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/core/wireless.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

--- net-2.6.22.orig/net/core/wireless.c	2007-03-07 15:16:15.000000000 -0800
+++ net-2.6.22/net/core/wireless.c	2007-03-07 15:16:37.000000000 -0800
@@ -346,8 +346,7 @@
 		.max_tokens	= sizeof(struct iw_pmksa),
 	},
 };
-static const unsigned standard_ioctl_num = (sizeof(standard_ioctl) /
-					    sizeof(struct iw_ioctl_description));
+static const unsigned standard_ioctl_num = ARRAY_SIZE(standard_ioctl);
 
 /*
  * Meta-data about all the additional standard Wireless Extension events
@@ -397,8 +396,7 @@
 		.max_tokens	= sizeof(struct iw_pmkid_cand),
 	},
 };
-static const unsigned standard_event_num = (sizeof(standard_event) /
-					    sizeof(struct iw_ioctl_description));
+static const unsigned standard_event_num = ARRAY_SIZE(standard_event);
 
 /* Size (in bytes) of the various private data types */
 static const char iw_priv_type_size[] = {

--
Stephen Hemminger <shemminger@linux-foundation.org>

