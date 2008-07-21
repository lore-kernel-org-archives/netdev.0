From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 23/31] netns ct: SIP conntracking in netns
Date: Mon, 21 Jul 2008 20:52:30 +0400
Message-ID: <20080721165230.GI13390@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	dev@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:10269 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbYGUQyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:54:19 -0400
Received: by ug-out-1314.google.com with SMTP id h2so277238ugf.16
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 09:54:16 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_sip.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -775,7 +775,7 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb,
 
 	rcu_read_lock();
 	do {
-		exp = __nf_ct_expect_find(&init_net, &tuple);
+		exp = __nf_ct_expect_find(nf_ct_net(ct), &tuple);
 
 		if (!exp || exp->master == ct ||
 		    nfct_help(exp->master)->helper != nfct_help(ct)->helper ||
-- 
1.5.4.5


