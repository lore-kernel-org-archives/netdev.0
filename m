From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/3] ipv6: Enable auto flow labels by default
Date: Thu, 30 Jul 2015 09:54:22 -0700
Message-ID: <1438275262-3708460-4-git-send-email-tom@herbertland.com>
References: <1438275262-3708460-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58288 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751148AbbG3QzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 12:55:16 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6UGoiYu018144
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 09:55:16 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vypux0ae1-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 09:55:16 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 bf9659c036db11e596340002c99293a0-3bff12b0 for <netdev@vger.kernel.org>;	Thu,
 30 Jul 2015 09:55:14 -0700
In-Reply-To: <1438275262-3708460-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flip the bit to initialize auto_flowlabels systcl to be 1.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/af_inet6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 9503bbf..1c7da26 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -768,7 +768,7 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.bindv6only = 0;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 	net->ipv6.sysctl.flowlabel_consistency = 1;
-	net->ipv6.sysctl.auto_flowlabels = 0;
+	net->ipv6.sysctl.auto_flowlabels = 1;
 	net->ipv6.sysctl.idgen_retries = 3;
 	net->ipv6.sysctl.idgen_delay = 1 * HZ;
 	net->ipv6.sysctl.flowlabel_state_ranges = 0;
-- 
1.8.5.6
