From: Jason Lunz <lunz@falooley.org>
Subject: Re: [ANN] removal of certain net drivers coming soon: eepro100, xircom_tulip_cb, iph5526
Date: Sat, 29 Jan 2005 20:42:33 +0000 (UTC)
Message-ID: <ctgsfp$hpa$1@sea.gmane.org>
References: <41F952F4.7040804@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

["Followup-To:" header set to gmane.linux.kernel.]
jgarzik@pobox.com said:
> 3) eepro100
>
> Unmaintained; users should use e100.
>
> When I last mentioned eepro100 was going away, I got a few private 
> emails saying complaining about issues not yet taken care of in e100. 
> eepro100 will not be removed until these issues are resolved.

I have an intel eepro100 card in an old PII 266. With eepro100, it gets
~9Mbit, but e100 struggles to keep its head above 1Mbit, and is very
erratic.

Also, drivers/net/Kconfig still claims that E100_NAPI exists, but the
option to disable napi has long since been removed from the driver.

Jason

--- linux-2.6.10/drivers/net/Kconfig.pre	2005-01-29 15:40:48.000000000 -0500
+++ linux-2.6.10/drivers/net/Kconfig	2005-01-29 15:41:01.000000000 -0500
@@ -1435,23 +1435,6 @@
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
