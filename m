From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH 4/5] netfilter: Fix format string mismatch in nf_conntrack_irc_init()
Date: Tue,  1 Apr 2014 00:43:38 +0900
Message-ID: <1396280619-31152-3-git-send-email-standby24x7@gmail.com>
References: <1396280619-31152-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: netdev@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396280619-31152-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix format string mismatch in nf_conntrack_irc_init()

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/netfilter/nf_conntrack_irc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 0fd2976..8ee3a5f 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -263,7 +263,7 @@ static int __init nf_conntrack_irc_init(void)
 		if (ports[i] == IRC_PORT)
 			sprintf(irc[i].name, "irc");
 		else
-			sprintf(irc[i].name, "irc-%u", i);
+			sprintf(irc[i].name, "irc-%d", i);
 
 		ret = nf_conntrack_helper_register(&irc[i]);
 		if (ret) {
-- 
1.9.1.352.gd393d14
