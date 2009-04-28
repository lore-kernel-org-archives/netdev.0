From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: inet_diag: Remove dup assignments
Date: Tue, 28 Apr 2009 10:56:36 -0300
Message-ID: <20090428135636.GF19908@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46917 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751812AbZD1N4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 09:56:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are later assigned to other values without being used meanwhile.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 588a779..b0b2735 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -198,8 +198,6 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 		tmo = 0;
 
 	r->idiag_family	      = tw->tw_family;
-	r->idiag_state	      = tw->tw_state;
-	r->idiag_timer	      = 0;
 	r->idiag_retrans      = 0;
 	r->id.idiag_if	      = tw->tw_bound_dev_if;
 	r->id.idiag_cookie[0] = (u32)(unsigned long)tw;
