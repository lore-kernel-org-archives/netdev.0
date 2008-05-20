From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: cls_api: fix return value for non-existant classifiers
Date: Tue, 20 May 2008 13:20:13 +0200
Message-ID: <4832B3ED.50900@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060906020101090604010303"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36108 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525AbYETLUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 07:20:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060906020101090604010303
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------060906020101090604010303
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 32fcfbb0b16a119534a0cfe750a0925b3c710b39
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue May 20 04:27:25 2008 +0200

    [NET_SCHED]: cls_api: fix return value for non-existant classifiers
    
    cls_api should return ENOENT when the requested classifier doesn't
    exist.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 1086df7..9360fc8 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -220,7 +220,7 @@ replay:
 		tp = kzalloc(sizeof(*tp), GFP_KERNEL);
 		if (tp == NULL)
 			goto errout;
-		err = -EINVAL;
+		err = -ENOENT;
 		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND]);
 		if (tp_ops == NULL) {
 #ifdef CONFIG_KMOD

--------------060906020101090604010303--
