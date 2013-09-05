From: Dave Jones <davej@redhat.com>
Subject: [PATCH] Add missing braces to do_tcp_setsockopt
Date: Thu, 5 Sep 2013 13:43:34 -0400
Message-ID: <20130905174333.GA3021@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57764 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752523Ab3IERnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 13:43:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dave Jones <davej@fedoraproject.org>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b2f6c74..95544e4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2454,10 +2454,11 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_THIN_DUPACK:
 		if (val < 0 || val > 1)
 			err = -EINVAL;
-		else
+		else {
 			tp->thin_dupack = val;
 			if (tp->thin_dupack)
 				tcp_disable_early_retrans(tp);
+		}
 		break;
 
 	case TCP_REPAIR:
