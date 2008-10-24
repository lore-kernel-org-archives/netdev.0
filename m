From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 1/2] Phonet: include generic link-layer header size in MAX_PHONET_HEADER
Date: Fri, 24 Oct 2008 17:55:38 +0300
Message-ID: <1224860139-23097-1-git-send-email-remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:20398 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbYJXPAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 11:00:48 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m9OF0YTi018739
	for <netdev@vger.kernel.org>; Fri, 24 Oct 2008 18:00:45 +0300
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes an OOPS in hard_header if a Phonet address is assigned to
a non-Phonet network interface.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index d4e7250..c6a2451 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -27,7 +27,7 @@
  * The lower layers may not require more space, ever. Make sure it's
  * enough.
  */
-#define MAX_PHONET_HEADER	8
+#define MAX_PHONET_HEADER	(8 + MAX_HEADER)
 
 /*
  * Every Phonet* socket has this structure first in its
-- 
1.5.4.3

