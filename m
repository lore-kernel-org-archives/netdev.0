From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] iptables: iptables: Remove exceptional & on function name
Date: Sun,  2 Apr 2017 14:55:37 +0530
Message-ID: <20170402092537.22968-1-arushisinghal19971997@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arushi Singhal <arushisinghal19971997@gmail.com>
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove & from function pointers to conform to the style found elsewhere
in the file. Done using the following semantic patch

// <smpl>
@r@
identifier f;
@@

f(...) { ... }
@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 iptables/ip6tables-save.c | 2 +-
 iptables/iptables-save.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/iptables/ip6tables-save.c b/iptables/ip6tables-save.c
index 053413a..683b143 100644
--- a/iptables/ip6tables-save.c
+++ b/iptables/ip6tables-save.c
@@ -66,7 +66,7 @@ static int do_output(const char *tablename)
 	const char *chain = NULL;
 
 	if (!tablename)
-		return for_each_table(&do_output);
+		return for_each_table(do_output);
 
 	h = ip6tc_init(tablename);
 	if (h == NULL) {
diff --git a/iptables/iptables-save.c b/iptables/iptables-save.c
index e8ae9c6..2b45720 100644
--- a/iptables/iptables-save.c
+++ b/iptables/iptables-save.c
@@ -64,7 +64,7 @@ static int do_output(const char *tablename)
 	const char *chain = NULL;
 
 	if (!tablename)
-		return for_each_table(&do_output);
+		return for_each_table(do_output);
 
 	h = iptc_init(tablename);
 	if (h == NULL) {
-- 
2.11.0
