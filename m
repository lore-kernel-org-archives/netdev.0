From: Tushar Gohad <tgohad@mvista.com>
Subject: [PATCH] IPv6/addrconf:  Fix minor addrlabel thinko
Date: Mon, 07 Sep 2009 23:04:03 -0700
Message-ID: <4AA5F3D3.80706@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:30985 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453AbZIHG2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 02:28:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fix apparent thinko related to RTM_DELADDRLABEL, introduced by commit 2a8cc6c89039e0530a3335954253b76ed0f9339a.


Signed-off-by: Tushar Gohad <tgohad@mvista.com>
---
 include/linux/rtnetlink.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index ba3254e..adf2068 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -104,7 +104,7 @@
 	RTM_NEWADDRLABEL = 72,
 #define RTM_NEWADDRLABEL RTM_NEWADDRLABEL
 	RTM_DELADDRLABEL,
-#define RTM_NEWADDRLABEL RTM_NEWADDRLABEL
+#define RTM_DELADDRLABEL RTM_DELADDRLABEL
 	RTM_GETADDRLABEL,
 #define RTM_GETADDRLABEL RTM_GETADDRLABEL
 
-- 
1.6.3.3.202.g91879

