From: Scott Feldman <sfeldma@pobox.com>
Subject: [PATCH 2.6] e100: remove reference to NAPI config option
Date: Mon, 31 Jan 2005 17:22:32 -0800
Message-ID: <1107220952.3366.4.camel@sfeldma-mobl.dsl-verizon.net>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lunz@falooley.org
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

e100 is NAPI all the time, so the Kconfig option is wasting space.

Signed-off-by: Scott Feldman <sfeldma@pobox.com>

--- linux-2.6.11-rc2/drivers/net/Kconfig.orig	2005-01-31 17:10:44.900111944 -0800
+++ linux-2.6.11-rc2/drivers/net/Kconfig	2005-01-31 17:10:52.137011768 -0800
@@ -1428,23 +1428,6 @@
 	  <file:Documentation/networking/net-modules.txt>.  The module
 	  will be called e100.
 
-config E100_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on E100
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card. It is
-	  still somewhat experimental and thus not yet enabled by default.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
-	  If in doubt, say N.
-
 config LNE390
 	tristate "Mylex EISA LNE390A/B support (EXPERIMENTAL)"
 	depends on NET_PCI && EISA && EXPERIMENTAL
--- linux-2.6.11-rc2/Documentation/networking/e100.txt.orig	2005-01-31 17:11:36.387284704 -0800
+++ linux-2.6.11-rc2/Documentation/networking/e100.txt	2005-01-31 17:12:36.503145704 -0800
@@ -140,8 +140,7 @@
   NAPI
   ----
 
-  NAPI (Rx polling mode) is supported in the e100 driver. NAPI is enabled
-  or disabled based on the configuration of the kernel. 
+  NAPI (Rx polling mode) is supported in the e100 driver.
 
   See www.cyberus.ca/~hadi/usenix-paper.tgz for more information on NAPI.
 
