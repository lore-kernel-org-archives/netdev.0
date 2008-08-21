From: adobriyan@gmail.com
Subject: [PATCH 38/38] netns nat: PPTP NAT in netns
Date: Fri, 22 Aug 2008 02:10:57 +0400
Message-ID: <20080821221057.GL31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:39836 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760459AbYHUWJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:09:46 -0400
Received: by yx-out-2324.google.com with SMTP id 8so103380yxm.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:09:45 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/netfilter/nf_nat_pptp.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -73,7 +73,7 @@ static void pptp_nat_expected(struct nf_conn *ct,
 
 	pr_debug("trying to unexpect other dir: ");
 	nf_ct_dump_tuple_ip(&t);
-	other_exp = nf_ct_expect_find_get(&init_net, &t);
+	other_exp = nf_ct_expect_find_get(nf_ct_net(ct), &t);
 	if (other_exp) {
 		nf_ct_unexpect_related(other_exp);
 		nf_ct_expect_put(other_exp);
-- 
1.5.6.3


