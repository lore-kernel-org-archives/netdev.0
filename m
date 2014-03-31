From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH 5/5] netfilter: Fix format string mismatch in nf_conntrack_sip_init()
Date: Tue,  1 Apr 2014 00:43:39 +0900
Message-ID: <1396280619-31152-4-git-send-email-standby24x7@gmail.com>
References: <1396280619-31152-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: netdev@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396280619-31152-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix format string mismatch in nf_conntrack_sip_init().

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/netfilter/nf_conntrack_sip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 4c3ba1c..ef82019 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1659,7 +1659,7 @@ static int __init nf_conntrack_sip_init(void)
 			if (ports[i] == SIP_PORT)
 				sprintf(sip[i][j].name, "sip");
 			else
-				sprintf(sip[i][j].name, "sip-%u", i);
+				sprintf(sip[i][j].name, "sip-%d", i);
 
 			pr_debug("port #%u: %u\n", i, ports[i]);
 
-- 
1.9.1.352.gd393d14
