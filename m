From: "Ian Brown" <ianbrn@gmail.com>
Subject: [PATCH] correct typo in __xfrm4_bundle_create()
Date: Wed, 5 Dec 2007 12:49:52 +0200
Message-ID: <d0383f90712050249q3bc0e249h4cb66dc0ea97f172@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:6095 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbXLEKuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 05:50:05 -0500
Received: by py-out-1112.google.com with SMTP id u77so956850pyb
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2007 02:50:03 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
 This is a typo correction in net/ipv4/xfrm4_policy.c; it should be
"Copy neighbour" instead "Copy neighbout",


Regards,
Ian Brown

Signed-off-by: ianbrn@gmail.com

diff --git a/a/net/ipv4/xfrm4_policy.c b/b/net/ipv4/xfrm4_policy.c
index cc86fb1..390dc7c 100644
--- a/a/net/ipv4/xfrm4_policy.c
+++ b/b/net/ipv4/xfrm4_policy.c
@@ -165,7 +165,7 @@ __xfrm4_bundle_create(struct xfrm_policy *policy,
struct xfrm_state **xfrm, int
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));

-		/* Copy neighbout for reachability confirmation */
+		/* Copy neighbour for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
 		dst_prev->output = dst_prev->xfrm->outer_mode->afinfo->output;
