From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH v2]net:8021q:vlan.c Fix pr_info to just give the vlan fullname and version.
Date: Mon, 23 May 2011 22:40:47 -0700
Message-ID: <1306215647-2857-1-git-send-email-justinmattock@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>,
	Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The below patch removes vlan_buggyright and vlan_copyright from vlan_proto_init, 
so that it prints out just the fullname of vlan and the version number.

before:

[   30.438203] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
[   30.441542] All bugs added by David S. Miller <davem@redhat.com>

after:

[   31.513910] 802.1Q VLAN Support v1.8

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
CC: Joe Perches <joe@perches.com>
CC: David S. Miller <davem@davemloft.net>
CC: Ben Greear <greearb@candelatech.com>
---
 net/8021q/vlan.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index b2274d1..9df3fcb 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -673,8 +673,7 @@ static int __init vlan_proto_init(void)
 {
 	int err;
 
-	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright);
-	pr_info("All bugs added by %s\n", vlan_buggyright);
+	pr_info("%s v%s\n", vlan_fullname, vlan_version);
 
 	err = register_pernet_subsys(&vlan_net_ops);
 	if (err < 0)
-- 
1.7.5.1
