From: "Noah J. Misch" <noah@caltech.edu>
Subject: [PATCH] Make VLSI FIR depend on X86
Date: Sun, 19 Oct 2003 23:41:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.58.0310171456080.13905@blinky>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: irda-users@lists.sourceforge.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Greetings,

This is a trivial patch against the Kconfig entry for the VLSI FIR driver to
make it depend on X86.  The in-tree code guarantees that the driver will only
build on X86, and according to the comments therein no machine of another
architecture has this hardware anyway.

Granted, no human intelligently configuring a kernel for his or her particular
system would make this mistake, but perhaps someone building a distribution
kernel would.  I suggest this patch because it keeps the signal to noise ratio
for those testing allyesconfig builds low.

This patch applies to the linux-2.5 BK tree as of 0400 UTC 10/20/2003, and for
some time before that as well.  Please consider for eventual inclusion.  It may
be too much of a fringe case until 2.6.0 begins its stable series.

Thanks,
Noah

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1373  -> 1.1374
#	drivers/net/irda/Kconfig	1.12    -> 1.13
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/16	noah@caltech.edu	1.1374
# Make VLSI_FIR depend on X86.  Read the comment just above the #error in
# include/net/irda/vlsi_ir.h for the reason; for now, this driver can never
# compile elsewhere.
# --------------------------------------------
#
diff -Nru a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
--- a/drivers/net/irda/Kconfig	Fri Oct 17 13:42:39 2003
+++ b/drivers/net/irda/Kconfig	Fri Oct 17 13:42:39 2003
@@ -284,7 +284,7 @@

 config VLSI_FIR
 	tristate "VLSI 82C147 SIR/MIR/FIR (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && PCI
+	depends on EXPERIMENTAL && IRDA && PCI && X86
 	help
 	  Say Y here if you want to build support for the VLSI 82C147
 	  PCI-IrDA Controller. This controller is used by the HP OmniBook 800
