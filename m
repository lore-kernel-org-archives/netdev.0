From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] tcp_probe: use GCC printf attribute
Date: Mon, 21 May 2007 09:02:51 -0700
Message-ID: <20070521090251.55ebd595@freepuppy>
References: <11797335421143-git-send-email-sangtae.ha@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sangtae Ha <sangtae.ha@gmail.com>
To: Sangtae Ha <sangtae.ha@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:55333 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756561AbXEUQHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 12:07:55 -0400
In-Reply-To: <11797335421143-git-send-email-sangtae.ha@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function in tcp_probe is printf like, use GCC to check the args.

Sighed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/ipv4/tcp_probe.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/ipv4/tcp_probe.c	2007-05-21 08:48:29.000000000 -0700
+++ b/net/ipv4/tcp_probe.c	2007-05-21 08:50:32.000000000 -0700
@@ -80,7 +80,8 @@ static void printl(const char *fmt, ...)
 
 	kfifo_put(tcpw.fifo, tbuf, len);
 	wake_up(&tcpw.wait);
-}
+} __attribute__ ((format (printf, 1, 2)));
+
 
 /*
  * Hook inserted to be called before each receive packet.
