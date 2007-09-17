From: "Ian Brown" <ianbrn@gmail.com>
Subject: [RFC][PATCH] trivial typo correction in net/ipv4/xfrm4_policy.c
Date: Mon, 17 Sep 2007 09:50:15 +0200
Message-ID: <d0383f90709170050k3694b52id8fdcd90c4ece005@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:55226 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbXIQHuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 03:50:16 -0400
Received: by py-out-1112.google.com with SMTP id u77so3004271pyb
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 00:50:15 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
  This is a  trivial typo correction in net/ipv4/xfrm4_policy.c which
hunted my eye...

Regards,
Ian Brown

Signed-off-by: ianbrn@gmail.com


--- linux-2.6.23-rc5-clean/net/ipv4/xfrm4_policy.c	2007-09-01
09:08:24.000000000 +0300
+++ linux-2.6.23-rc5/net/ipv4/xfrm4_policy.c	2007-09-17 09:36:04.000000000 +0200
@@ -166,7 +166,7 @@
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));

-		/* Copy neighbout for reachability confirmation */
+		/* Copy neighbour for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
 		/* XXX: When IPv6 module can be unloaded, we should manage reference
