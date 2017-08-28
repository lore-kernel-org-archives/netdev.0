From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net-next 2/2] man: add documentation for seg6 l2encap mode
Date: Mon, 28 Aug 2017 20:05:25 +0100
Message-ID: <20170828190525.15655-3-david.lebrun@uclouvain.be>
References: <20170828190525.15655-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:40410 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751322AbdH1TE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:04:57 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp6.sgsi.ucl.ac.be (Postfix) with ESMTPS id DEEF367DAA2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 21:04:47 +0200 (CEST)
In-Reply-To: <20170828190525.15655-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds documentation for the seg6 L2ENCAP encapsulation mode.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 man/man8/ip-route.8.in | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 11dd9d0..803de3b 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -214,7 +214,7 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .IR ENCAP_SEG6 " := "
 .B seg6
 .BR mode " [ "
-.BR encap " | " inline " ] "
+.BR encap " | " inline " | " l2encap " ] "
 .B segs
 .IR SEGMENTS " [ "
 .B hmac
@@ -750,6 +750,10 @@ is a set of encapsulation attributes specific to the
 - Encapsulate packet in an outer IPv6 header with SRH
 .sp
 
+.B mode l2encap
+- Encapsulate ingress L2 frame within an outer IPv6 header and SRH
+.sp
+
 .I SEGMENTS
 - List of comma-separated IPv6 addresses
 .sp
-- 
2.10.2
