From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc4] bonding: fix typos in bonding documentation
Date: Tue, 18 Oct 2005 21:30:59 -0400
Message-ID: <10182005213059.12167@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, ctindel@users.sourceforge.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932447AbVJSBdd@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix some simple typos in the bonding.txt file.  The typos are in areas
relating to loading the bonding driver multiple times.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 Documentation/networking/bonding.txt |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -777,7 +777,7 @@ doing so is the same as described in the
 Manually" section, below.
 
 	NOTE: It has been observed that some Red Hat supplied kernels
-are apparently unable to rename modules at load time (the "-obonding1"
+are apparently unable to rename modules at load time (the "-o bond1"
 part).  Attempts to pass that option to modprobe will produce an
 "Operation not permitted" error.  This has been reported on some
 Fedora Core kernels, and has been seen on RHEL 4 as well.  On kernels
@@ -883,7 +883,8 @@ the above does not work, and the second 
 its options.  In that case, the second options line can be substituted
 as follows:
 
-install bonding1 /sbin/modprobe bonding -obond1 mode=balance-alb miimon=50
+install bond1 /sbin/modprobe --ignore-install bonding -o bond1 \
+	mode=balance-alb miimon=50
 
 	This may be repeated any number of times, specifying a new and
 unique name in place of bond1 for each subsequent instance.
