From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 3/6] mpls: Better error code for unsupported option.
Date: Sat, 07 Mar 2015 16:22:40 -0600
Message-ID: <87fv9g4fdb.fsf@x220.int.ebiederm.org>
References: <874mpw5u3x.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:49690 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbbCGW0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 17:26:17 -0500
In-Reply-To: <874mpw5u3x.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sat, 07 Mar 2015 16:18:58 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/mpls/af_mpls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 0f2833e1b233..5c99e3fc1b72 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -348,7 +348,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		goto errout;
 
 	/* Append makes no sense with mpls */
-	err = -EINVAL;
+	err = -EOPNOTSUPP;
 	if (cfg->rc_nlflags & NLM_F_APPEND)
 		goto errout;
 
-- 
2.2.1
