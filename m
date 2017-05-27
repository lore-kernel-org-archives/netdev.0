From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 9/9] net: mpls: remove unnecessary initialization of err
Date: Sat, 27 May 2017 16:19:33 -0600
Message-ID: <20170527221933.57644-10-dsahern@gmail.com>
References: <20170527221933.57644-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35606 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750797AbdE0WTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 18:19:53 -0400
Received: by mail-pg0-f66.google.com with SMTP id i63so2470142pgd.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 15:19:52 -0700 (PDT)
In-Reply-To: <20170527221933.57644-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

err is initialized to EINVAL and not used before it is set again.
Remove the unnecessary initialization.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/mpls/af_mpls.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index a953fcf169ba..94b3317232a6 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -743,8 +743,6 @@ static int mpls_nh_build_from_cfg(struct mpls_route_config *cfg,
 	if (!nh)
 		return -ENOMEM;
 
-	err = -EINVAL;
-
 	nh->nh_labels = cfg->rc_output_labels;
 	for (i = 0; i < nh->nh_labels; i++)
 		nh->nh_label[i] = cfg->rc_output_label[i];
-- 
2.11.0 (Apple Git-81)
