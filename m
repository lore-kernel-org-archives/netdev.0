From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/3) Space.c -- update comment
Date: Tue, 23 Sep 2003 10:12:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923101235.54120264.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Keep comments and current status in sync.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Sep 23 09:37:04 2003
+++ b/drivers/net/Space.c	Tue Sep 23 09:37:04 2003
@@ -12,18 +12,15 @@
  *		Donald J. Becker, <becker@scyld.com>
  *
  * Changelog:
+ *		Stephen Hemminger (09/2003)
+ *		- get rid of pre-linked dev list, dynamic device allocation
  *		Paul Gortmaker (03/2002)
-		- struct init cleanup, enable multiple ISA autoprobes.
+ *		- struct init cleanup, enable multiple ISA autoprobes.
  *		Arnaldo Carvalho de Melo <acme@conectiva.com.br> - 09/1999
  *		- fix sbni: s/device/net_device/
  *		Paul Gortmaker (06/98): 
  *		 - sort probes in a sane way, make sure all (safe) probes
  *		   get run once & failed autoprobes don't autoprobe again.
- *
- *	FIXME:
- *		Phase out placeholder dev entries put in the linked list
- *		here in favour of drivers using init_etherdev(NULL, ...)
- *		combined with a single find_all_devs() function (for 2.3)
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
