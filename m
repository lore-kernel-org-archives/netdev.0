From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] netdev: Update status of 8390 based drivers in MAINTAINERS
Date: Sat,  1 Jan 2011 18:28:30 -0500
Message-ID: <1293924510-14290-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57562 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973Ab1AAX3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 18:29:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the original 8 bit ISA ne1000 card being over 20 years old, it
only makes sense to consider ne.c and all the other toplevel 8390
based driver files as legacy for obsolete hardware.  The most
recent thing made in large quantities that was 8390 based were
those crazy PCI ne2k clones - and even they are now 10+ years old.

Also remove myself as maintainer, since the only changes to these
drivers going forward will be the generic API type changes that
touch all drivers.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 MAINTAINERS |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 4641289..aa835f7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -166,9 +166,8 @@ F:	drivers/serial/8250*
 F:	include/linux/serial_8250.h
 
 8390 NETWORK DRIVERS [WD80x3/SMC-ELITE, SMC-ULTRA, NE2000, 3C503, etc.]
-M:	Paul Gortmaker <p_gortmaker@yahoo.com>
 L:	netdev@vger.kernel.org
-S:	Maintained
+S:	Orphan / Obsolete
 F:	drivers/net/*8390*
 F:	drivers/net/ax88796.c
 
-- 
1.7.3.3

