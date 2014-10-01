From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ieee802154: fix __init functions
Date: Wed,  1 Oct 2014 07:27:46 +0200
Message-ID: <1412141266-12258-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Alexander Aring <alex.aring@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 3243acd37fd9
("ieee802154: add __init to lowpan_frags_sysctl_register")

added __init to lowpan_frags_ns_sysctl_register instead of
lowpan_frags_sysctl_register

Suggested-by: Alexander Aring <alex.aring@gmail.com>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ieee802154/reassembly.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index 30ec608..7cfcd68 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -498,7 +498,7 @@ static void lowpan_frags_sysctl_unregister(void)
 	unregister_net_sysctl_table(lowpan_ctl_header);
 }
 #else
-static inline int __init lowpan_frags_ns_sysctl_register(struct net *net)
+static inline int lowpan_frags_ns_sysctl_register(struct net *net)
 {
 	return 0;
 }
@@ -507,7 +507,7 @@ static inline void lowpan_frags_ns_sysctl_unregister(struct net *net)
 {
 }
 
-static inline int lowpan_frags_sysctl_register(void)
+static inline int __init lowpan_frags_sysctl_register(void)
 {
 	return 0;
 }
-- 
1.9.3
