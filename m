From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] netlabel: kernel-doc warning fix
Date: Tue,  7 Oct 2014 22:31:32 +0200
Message-ID: <1412713892-5537-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Paul Moore <paul@paul-moore.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay002.isp.belgacom.be ([195.238.6.175]:29151 "EHLO
	mailrelay002.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751712AbaJGUbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 16:31:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

no secid argument in netlbl_cfg_unlbl_static_del

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/netlabel/netlabel_kapi.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 0b4692d..a845cd4 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -246,7 +246,6 @@ int netlbl_cfg_unlbl_static_add(struct net *net,
  * @addr: IP address in network byte order (struct in[6]_addr)
  * @mask: address mask in network byte order (struct in[6]_addr)
  * @family: address family
- * @secid: LSM secid value for the entry
  * @audit_info: NetLabel audit information
  *
  * Description:
-- 
1.9.3
