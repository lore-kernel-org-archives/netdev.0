From: Chris Wright <chrisw@sous-sol.org>
Subject: [patch 60/69] sky2: 88e8071 support not ready
Date: Mon, 21 May 2007 12:17:12 -0700
Message-ID: <20070521191753.357017000@sous-sol.org>
References: <20070521191612.800400000@sous-sol.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:46483 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758511AbXEUTWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 15:22:07 -0400
Content-Disposition: inline; filename=sky2-88e8071-support-not-ready.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.
---------------------

From: Stephen Hemminger <shemminger@linux-foundation.org>

The driver is not ready to support 88e8071 chip, it requires several
more changes (not done yet). If this chip is present, system will hang on boot.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.21.1.orig/drivers/net/sky2.c
+++ linux-2.6.21.1/drivers/net/sky2.c
@@ -129,7 +129,7 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4369) }, /* 88EC042 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436A) }, /* 88E8058 */
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
+//	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
 	{ 0 }
 };
 

-- 
