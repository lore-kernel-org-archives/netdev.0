From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/2] vxlan: synchronize <linux/if_link.h> header
Date: Thu, 15 Jan 2015 14:54:26 +0100
Message-ID: <11c03165774130337684aceb930b18a876a3ead3.1421329802.git.tgraf@suug.ch>
References: <cover.1421329802.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57974 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbbAONye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 08:54:34 -0500
In-Reply-To: <cover.1421329802.git.tgraf@suug.ch>
In-Reply-To: <cover.1421329802.git.tgraf@suug.ch>
References: <cover.1421329802.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/if_link.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 167ec34..0b33d0a 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -368,6 +368,9 @@ enum {
 	IFLA_VXLAN_UDP_CSUM,
 	IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
 	IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
+	IFLA_VXLAN_REMCSUM_TX,
+	IFLA_VXLAN_REMCSUM_RX,
+	IFLA_VXLAN_GBP,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
-- 
1.9.3
