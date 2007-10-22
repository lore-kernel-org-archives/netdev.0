From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [RFC][PATCH 3/3][XFRM]: Add packet processing statistics option.
Date: Mon, 22 Oct 2007 15:11:26 +0900
Message-ID: <11930334862373-git-send-email-nakam@linux-ipv6.org>
References: <20071017.213523.58458049.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:47270 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbXJVGcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 02:32:17 -0400
In-Reply-To: <20071017.213523.58458049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

