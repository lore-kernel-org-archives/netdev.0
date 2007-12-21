From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 3/3] [XFRM]: Add packet processing statistics option.
Date: Fri, 21 Dec 2007 12:42:04 +0900
Message-ID: <119820852455-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:58064 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754923AbXLUEJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:09:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/xfrm/Kconfig |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 577a4f8..6b5b50f 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -35,6 +35,16 @@ config XFRM_MIGRATE
 
 	  If unsure, say N.
 
+config XFRM_STATISTICS
+	bool "Transformation statistics (EXPERIMENTAL)"
+	depends on XFRM && PROC_FS && EXPERIMENTAL
+	---help---
+	  This statistics is not a SNMP/MIB specification but shows
+	  statistics about transformation error (or almost error) factor
+	  at packet processing for developer.
+
+	  If unsure, say N.
+
 config NET_KEY
 	tristate "PF_KEY sockets"
 	select XFRM
-- 
1.4.4.2

