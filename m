From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] net/dccp/proto.c: add __init to dccp_mib_init
Date: Wed,  1 Oct 2014 06:48:03 +0200
Message-ID: <1412138883-2476-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	"David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay002.isp.belgacom.be ([195.238.6.175]:10520 "EHLO
	mailrelay002.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750750AbaJAEsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 00:48:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dccp_mib_init is only called by __init dccp_init in same module.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/dccp/proto.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index e421edd..6d090c4 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1082,7 +1082,7 @@ void dccp_shutdown(struct sock *sk, int how)
 
 EXPORT_SYMBOL_GPL(dccp_shutdown);
 
-static inline int dccp_mib_init(void)
+static inline int __init dccp_mib_init(void)
 {
 	dccp_statistics = alloc_percpu(struct dccp_mib);
 	if (!dccp_statistics)
-- 
1.9.3
