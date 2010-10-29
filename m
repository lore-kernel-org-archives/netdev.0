From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 14/15] MAINTAINERS: updates for new drivers/net/legacy dir
Date: Thu, 28 Oct 2010 21:19:18 -0400
Message-ID: <1288315159-1350-15-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34002 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759641Ab0J2BTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:35 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers, particularly those which are greater than 10 years
old, have been moved off to a new legacy directory.  Update the
MAINTAINERS file to indicate this new path.

For the 8390 based drivers, change the status from maintained to
obsolete and remove the old e-mail address.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 MAINTAINERS |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 69aa8fe..5d499d1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -116,7 +116,7 @@ Maintainers List (try to look for most precise areas first)
 M:	Philip Blundell <philb@gnu.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/3c505*
+F:	drivers/net/legacy/3c505*
 
 3C59X NETWORK DRIVER
 M:	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
@@ -166,11 +166,10 @@ F:	drivers/serial/8250*
 F:	include/linux/serial_8250.h
 
 8390 NETWORK DRIVERS [WD80x3/SMC-ELITE, SMC-ULTRA, NE2000, 3C503, etc.]
-M:	Paul Gortmaker <p_gortmaker@yahoo.com>
 L:	netdev@vger.kernel.org
-S:	Maintained
-F:	drivers/net/*8390*
-F:	drivers/net/ax88796.c
+S:	Obsolete
+F:	drivers/net/legacy/*8390*
+F:	drivers/net/legacy/ax88796.c
 
 9P FILE SYSTEM
 M:	Eric Van Hensbergen <ericvh@gmail.com>
@@ -1945,7 +1944,7 @@ F:	net/decnet/
 DEFXX FDDI NETWORK DRIVER
 M:	"Maciej W. Rozycki" <macro@linux-mips.org>
 S:	Maintained
-F:	drivers/net/defxx.*
+F:	drivers/net/legacy/defxx.*
 
 DELL LAPTOP DRIVER
 M:	Matthew Garrett <mjg59@srcf.ucam.org>
@@ -2326,7 +2325,7 @@ ETHEREXPRESS-16 NETWORK DRIVER
 M:	Philip Blundell <philb@gnu.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/eexpress.*
+F:	drivers/net/legacy/eexpress.*
 
 ETHERNET BRIDGE
 M:	Stephen Hemminger <shemminger@linux-foundation.org>
@@ -2340,7 +2339,7 @@ F:	net/bridge/
 ETHERTEAM 16I DRIVER
 M:	Mika Kuoppala <miku@iki.fi>
 S:	Maintained
-F:	drivers/net/eth16i.c
+F:	drivers/net/legacy/eth16i.c
 
 EXT2 FILE SYSTEM
 M:	Jan Kara <jack@suse.cz>
@@ -4232,7 +4231,7 @@ M:	Jan-Pascal van Best <janpascal@vanbest.org>
 M:	Andreas Mohr <andi@lisas.de>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/ni5010.*
+F:	drivers/net/legacy/ni5010.*
 
 NILFS2 FILESYSTEM
 M:	KONISHI Ryusuke <konishi.ryusuke@lab.ntt.co.jp>
@@ -5975,7 +5974,7 @@ W:	http://uclinux-h8.sourceforge.jp/
 S:	Supported
 F:	arch/h8300/
 F:	drivers/ide/ide-h8300.c
-F:	drivers/net/ne-h8300.c
+F:	drivers/net/legacy/ne-h8300.c
 
 UDF FILESYSTEM
 M:	Jan Kara <jack@suse.cz>
-- 
1.7.3.2.146.g2d444

