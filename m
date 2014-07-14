From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 05/16] netlabel: remove unnecessary break after goto
Date: Mon, 14 Jul 2014 18:30:55 +0200
Message-ID: <1405355467-7350-6-git-send-email-fabf@skynet.be>
References: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay006.isp.belgacom.be ([195.238.6.172]:27168 "EHLO
	mailrelay006.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756570AbaGNQcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 12:32:04 -0400
In-Reply-To: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/netlabel/netlabel_kapi.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 3045a96..fe9415e 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -170,7 +170,6 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 #endif /* IPv6 */
 		default:
 			goto cfg_unlbl_map_add_failure;
-			break;
 		}
 
 		entry->def.addrsel = addrmap;
-- 
1.8.4.5
