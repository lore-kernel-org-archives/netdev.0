From: jamal <hadi@cyberus.ca>
Subject: [PATCH] pkt_sched: pedit use proper struct
Date: Sun, 11 Oct 2009 10:21:38 -0400
Message-ID: <1255270898.5406.6.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hiG8lhkXDWP/3DdHZlqB"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:24365 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201AbZJKOZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2009 10:25:44 -0400
Received: by qw-out-2122.google.com with SMTP id 9so362193qwb.37
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2009 07:24:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hiG8lhkXDWP/3DdHZlqB
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This probably deserves to go into -stable. 

cheers,
jamal

--=-hiG8lhkXDWP/3DdHZlqB
Content-Disposition: attachment; filename=patch-pedit
Content-Type: text/plain; name=patch-pedit; charset=UTF-8
Content-Transfer-Encoding: 7bit

commit 6debfdb8e600da8216399d182d6e52f1629c6b22
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Sun Oct 11 10:07:03 2009 -0400

    [PATCH] pkt_sched: pedit use proper struct
    
    Pedit will reject a policy that is large because it
    uses the wrong structure in the policy validation.
    This fixes it.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 96c0ed1..6b0359a 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -34,7 +34,7 @@ static struct tcf_hashinfo pedit_hash_info = {
 };
 
 static const struct nla_policy pedit_policy[TCA_PEDIT_MAX + 1] = {
-	[TCA_PEDIT_PARMS]	= { .len = sizeof(struct tcf_pedit) },
+	[TCA_PEDIT_PARMS]	= { .len = sizeof(struct tc_pedit) },
 };
 
 static int tcf_pedit_init(struct nlattr *nla, struct nlattr *est,

--=-hiG8lhkXDWP/3DdHZlqB--

