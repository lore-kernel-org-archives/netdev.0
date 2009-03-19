From: bernard pidoux <f6bvp@free.fr>
Subject: [PATCH 1/3] [AX25] SOCK_DEBUG message simplification
Date: Thu, 19 Mar 2009 19:11:48 +0100
Message-ID: <1237486308.30285.12.camel@f6bvp-11>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:58402 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbZCSS27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 14:28:59 -0400
Received: from smtp4-g21.free.fr (smtp4-g21.free.fr [212.27.42.4])
	by smtpfb2-g21.free.fr (Postfix) with ESMTP id F0E11CB3590
	for <netdev@vger.kernel.org>; Thu, 19 Mar 2009 19:28:52 +0100 (CET)
Received: from smtp4-g21.free.fr (localhost [127.0.0.1])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 473E24C811D
	for <netdev@vger.kernel.org>; Thu, 19 Mar 2009 19:27:38 +0100 (CET)
Received: from [192.168.0.66] (car75-2-82-66-61-83.fbx.proxad.net [82.66.61.83])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 582354C8072
	for <netdev@vger.kernel.org>; Thu, 19 Mar 2009 19:27:36 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch condenses two debug messages in one.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
 net/ax25/af_ax25.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 00d9e5e..532a031 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1529,10 +1529,8 @@ static int ax25_sendmsg(struct kiocb *iocb, struct socket *sock,
 		dp = ax25->digipeat;
 	}
 
-	SOCK_DEBUG(sk, "AX.25: sendto: Addresses built.\n");
-
 	/* Build a packet */
-	SOCK_DEBUG(sk, "AX.25: sendto: building packet.\n");
+	SOCK_DEBUG(sk, "AX.25: sendto: Addresses built. Building packet.\n");
 
 	/* Assume the worst case */
 	size = len + ax25->ax25_dev->dev->hard_header_len;
-- 
1.6.0.6

