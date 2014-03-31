From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH 3/5] netfilter: Fix format string mismatch in _conntrack_tftp_init()
Date: Tue,  1 Apr 2014 00:43:37 +0900
Message-ID: <1396280619-31152-2-git-send-email-standby24x7@gmail.com>
References: <1396280619-31152-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: netdev@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:58662 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbaCaPnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 11:43:49 -0400
In-Reply-To: <1396280619-31152-1-git-send-email-standby24x7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix format string mismatch in _conntrack_tftp_init().

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/netfilter/nf_conntrack_tftp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index e68ab4f..9b1608f 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -134,7 +134,7 @@ static int __init nf_conntrack_tftp_init(void)
 			if (ports[i] == TFTP_PORT)
 				sprintf(tftp[i][j].name, "tftp");
 			else
-				sprintf(tftp[i][j].name, "tftp-%u", i);
+				sprintf(tftp[i][j].name, "tftp-%d", i);
 
 			ret = nf_conntrack_helper_register(&tftp[i][j]);
 			if (ret) {
-- 
1.9.1.352.gd393d14
