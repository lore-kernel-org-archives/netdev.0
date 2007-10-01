From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/1][TCP]: break missing at end of switch statement
Date: Mon, 1 Oct 2007 13:32:43 +0100
Message-ID: <200710011332.43657@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:48504 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751510AbXJAMcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 08:32:36 -0400
Received: from gerrit (gerrit.erg.abdn.ac.uk [139.133.204.176])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id l91CWSVt011010
	for <netdev@vger.kernel.org>; Mon, 1 Oct 2007 13:32:28 +0100 (BST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TCP]: break missing at end of switch statement

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3129,6 +3129,7 @@ static void tcp_reset(struct sock *sk)
 			return;
 		default:
 			sk->sk_err = ECONNRESET;
+			break;
 	}
 
 	if (!sock_flag(sk, SOCK_DEAD))
