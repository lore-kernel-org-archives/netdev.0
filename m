From: Micah Gruber <micah.gruber@gmail.com>
Subject: [PATCH] Remove unneeded pointer newdp from dccp_v4_request_recv_sock()
 in net/dccp/ipv4.c
Date: Wed, 05 Sep 2007 13:47:05 +0800
Message-ID: <46DE42D9.2040200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.185]:24825 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754227AbXIEFpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 01:45:55 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1365163rvb
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2007 22:45:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This trivial patch removes the unneeded pointer newdp, which is never used.

Signed-off-by: Micah Gruber <micah.gruber@gmail.com>
---

--- a/net/dccp/ipv4.c	2007-09-04 23:18:42.000000000 +0800
+++ b/net/dccp/ipv4.c	2007-09-05 00:49:54.000000000 +0800
@@ -381,7 +381,6 @@
 {
 	struct inet_request_sock *ireq;
 	struct inet_sock *newinet;
-	struct dccp_sock *newdp;
 	struct sock *newsk;
 
 	if (sk_acceptq_is_full(sk))
@@ -396,7 +395,6 @@
 
 	sk_setup_caps(newsk, dst);
 
-	newdp		   = dccp_sk(newsk);
 	newinet		   = inet_sk(newsk);
 	ireq		   = inet_rsk(req);
 	newinet->daddr	   = ireq->rmt_addr;

