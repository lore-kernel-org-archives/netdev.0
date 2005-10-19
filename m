From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc4 3/3] Documentation: add sk98lin to the feature-removal-schedule
Date: Tue, 18 Oct 2005 21:31:00 -0400
Message-ID: <10182005213100.12480@bilbo.tuxdriver.com>
References: <10182005213100.12420@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, shemminger@osdl.org, mlindner@syskonnect.de,
	rroesler@syskonnect.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932438AbVJSBiv@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <10182005213100.12420@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sk98lin and skge drivers cover the same set of hardware, yet the
sk98lin driver is barely maintained.  This patch schedules sk98lin
for removal early next year.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 Documentation/feature-removal-schedule.txt |    9 +++++++++
 1 files changed, 9 insertions(+)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -95,3 +95,12 @@ Why:	This interface has been obsoleted b
 	to link against API-compatible library on top of libnfnetlink_queue 
 	instead of the current 'libipq'.
 Who:	Harald Welte <laforge@netfilter.org>
+
+---------------------------
+
+What:	sk98lin driver
+When:	April 2006
+Why:	This driver has been essentially unmaintained for some time.
+	Internally it is a mess, and the original authors are unwilling to
+	correct it.  Now the skge driver covers all the same hardware.
+Who:	John W. Linville <linville@tuxdriver.com>
