From: Erik Hensema <erik@hensema.net>
Subject: [Patch 2.4.21-pre4] Move khttpd config option
Date: Tue, 18 Feb 2003 13:15:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030218121531.GB5848@hensema.net>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="JP+T4n/bALQSJXh8"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--JP+T4n/bALQSJXh8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Currently the configure option for khttpd is below IPv6. This is confusing
when IPv6 has suboptions, like with the sit-promote-mark patch.

This patch moves the option.

-- 
Erik Hensema (erik@hensema.net)

--JP+T4n/bALQSJXh8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="move-khttpd.diff"

--- net/Config.in.orig	Sat Aug  3 02:39:46 2002
+++ net/Config.in	Tue Feb 18 13:04:58 2003
@@ -20,14 +20,14 @@
 if [ "$CONFIG_INET" = "y" ]; then
    source net/ipv4/Config.in
    if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then
+      source net/khttpd/Config.in
+   if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then
 #   IPv6 as module will cause a CRASH if you try to unload it
       tristate '  The IPv6 protocol (EXPERIMENTAL)' CONFIG_IPV6
       if [ "$CONFIG_IPV6" != "n" ]; then
 	 source net/ipv6/Config.in
       fi
    fi
-   if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then
-      source net/khttpd/Config.in
    fi
 fi
 if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then

--JP+T4n/bALQSJXh8--
