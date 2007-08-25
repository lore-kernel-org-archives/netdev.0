From: Thomas Graf <tgraf@suug.ch>
Subject: [XFRM] policy: Replace magic number with XFRM_POLICY_OUT
Date: Sat, 25 Aug 2007 12:53:41 +0200
Message-ID: <20070825105341.GB894@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:35885 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762405AbXHYKxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 06:53:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_policy.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_policy.c	2007-08-24 13:11:17.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_policy.c	2007-08-24 13:11:48.000000000 +0200
@@ -1477,7 +1477,7 @@ restart:
 	pol_dead = 0;
 	xfrm_nr = 0;
 
-	if (sk && sk->sk_policy[1]) {
+	if (sk && sk->sk_policy[XFRM_POLICY_OUT]) {
 		policy = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
 		if (IS_ERR(policy))
 			return PTR_ERR(policy);
