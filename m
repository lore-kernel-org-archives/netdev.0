From: Art Haas <ahaas@neosoft.com>
Subject: [PATCH] trivial C99 designated initializer fix for net/sctp/sm_statetable.c
Date: Mon, 7 Oct 2002 17:48:20 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021007224820.GO9856@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@transmeta.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

As the subject indicated, the patch is trivial. Patch is against 2.5.41.

Art Haas

--- linux-2.5.41/net/sctp/sm_statetable.c.old	2002-09-28 10:35:14.000000000 -0500
+++ linux-2.5.41/net/sctp/sm_statetable.c	2002-10-07 15:51:59.000000000 -0500
@@ -555,7 +555,7 @@
 	 .name = "sctp_sf_cookie_wait_prm_shutdown"}, \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
 	{.fn = sctp_sf_cookie_echoed_prm_shutdown, \
-	 name:"sctp_sf_cookie_echoed_prm_shutdown"},\
+	 .name = "sctp_sf_cookie_echoed_prm_shutdown"},\
 	/* SCTP_STATE_ESTABLISHED */ \
 	{.fn = sctp_sf_do_9_2_prm_shutdown, \
 	 .name = "sctp_sf_do_9_2_prm_shutdown"}, \
-- 
They that can give up essential liberty to obtain a little temporary safety
deserve neither liberty nor safety.
 -- Benjamin Franklin, Historical Review of Pennsylvania, 1759
