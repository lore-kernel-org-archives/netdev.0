From: Kris Katterjohn <katterjohn@gmail.com>
Subject: [PATCH] Fix tcp_v4_send_synack() comment
Date: Wed, 13 Feb 2008 19:03:59 -0600
Message-ID: <47B3937F.6010106@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050708010102040101060407"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.177]:6482 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758235AbYBNBEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 20:04:04 -0500
Received: by ik-out-1112.google.com with SMTP id c28so160338ika.5
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 17:04:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050708010102040101060407
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hey everyone,

I've attached a patch that fixes the comment above tcp_v4_send_synack() 
in ipv4/tcp_ipv4.c.

Signed-off-by: Kris Katterjohn <katterjohn@gmail.com>

Thanks,
Kris Katterjohn

--------------050708010102040101060407
Content-Type: text/x-patch;
 name="synack.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="synack.patch"

--- net/ipv4/tcp_ipv4.c	2008-02-10 23:51:11.000000000 -0600
+++ net/ipv4/tcp_ipv4.c	2008-02-13 18:31:44.000000000 -0600
@@ -735,7 +735,7 @@ static void tcp_v4_reqsk_send_ack(struct
 }
 
 /*
- *	Send a SYN-ACK after having received an ACK.
+ *	Send a SYN-ACK after having received a SYN.
  *	This still operates on a request_sock only, not on a big
  *	socket.
  */

--------------050708010102040101060407--
