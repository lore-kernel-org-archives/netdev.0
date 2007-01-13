From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 0/8] partial resend: e1000 fixes and updates
Date: Fri, 12 Jan 2007 16:36:50 -0800
Message-ID: <20070113003650.16816.34076.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1202 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161188AbXAMAyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jan 2007 19:54:11 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch series contains exclusively fixes for e1000. Some of these patches were
already sent in december, but didn't make it into any usptream tree yet. Most
importantly, it addresses two issues in the recently merged msi interrupt
handler and dynamic itr code. A performance fix and some minor cleanups are also
added. This brings the driver up to version 7.3.20-k2.

The summary below lists all patches. Once that were previously acked are annotated
with (*)

These patches apply against netdev-2.6 #upstream-linus commit
77aab8bf22042d1658d4adbca8b71779e7f2d0ff. Please pull:

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-linus

to receive them.

Cheers,

Auke

---
Bruce Allan <bruce.w.allan@intel.com>:
     e1000: clear ip csum info from context descriptor (*)

Jesse Brandeburg <jesse.brandeburg@intel.com>:
     e1000: simplify case handling gigabit at half duplex (*)
     e1000: Fix MSI only interrupt handler routine
     e1000: fix NAPI performance on 4-port adapters (*)
     e1000: tune our dynamic itr transmit packet accounting

Auke Kok <auke-jan.h.kok@intel.com>:
     e1000: clean up debug output defines
     e1000: display flow control of link status at link up (*)
     e1000: update version to 7.3.20-k2

---
 drivers/net/e1000/e1000.h       |    1
 drivers/net/e1000/e1000_main.c  |  102 ++++++++++++++++++----------------------
 drivers/net/e1000/e1000_osdep.h |    4 -
 drivers/net/e1000/e1000_param.c |   15 +----
 4 files changed, 51 insertions(+), 71 deletions(-)

---
Auke Kok <auke-jan.h.kok@intel.com>
