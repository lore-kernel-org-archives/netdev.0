From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] vxlan: make the struct nlattr variable const
Date: Sat,  3 Sep 2016 22:07:10 +0800
Message-ID: <1472911630-22285-1-git-send-email-zyjzyj2000@gmail.com>
To: netdev@vger.kernel.org, pabeni@redhat.com, daniel@iogearbox.net,
        pshelar@nicira.com, aduyck@mirantis.com,
        hannes@stressinduktion.org, jbenc@redhat.com, davem@davemloft.net,
        zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.221.46.213] ([221.221.46.213]:54862 "EHLO mail.rain.com"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752618AbcICOSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Sep 2016 10:18:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

The struct nlattr variable should not be changed.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/vxlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f605a36..ce65897 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -115,7 +115,7 @@ static inline bool vxlan_addr_multicast(const union vxlan_addr *ipa)
 		return IN_MULTICAST(ntohl(ipa->sin.sin_addr.s_addr));
 }
 
-static int vxlan_nla_get_addr(union vxlan_addr *ip, struct nlattr *nla)
+static int vxlan_nla_get_addr(union vxlan_addr *ip, const struct nlattr *nla)
 {
 	if (nla_len(nla) >= sizeof(struct in6_addr)) {
 		ip->sin6.sin6_addr = nla_get_in6_addr(nla);
@@ -157,7 +157,7 @@ static inline bool vxlan_addr_multicast(const union vxlan_addr *ipa)
 	return IN_MULTICAST(ntohl(ipa->sin.sin_addr.s_addr));
 }
 
-static int vxlan_nla_get_addr(union vxlan_addr *ip, struct nlattr *nla)
+static int vxlan_nla_get_addr(union vxlan_addr *ip, const struct nlattr *nla)
 {
 	if (nla_len(nla) >= sizeof(struct in6_addr)) {
 		return -EAFNOSUPPORT;
-- 
2.7.4
