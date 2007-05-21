From: Chris Wright <chrisw@sous-sol.org>
Subject: [patch 59/69] sky2: allow 88E8056
Date: Mon, 21 May 2007 12:17:11 -0700
Message-ID: <20070521191752.897413000@sous-sol.org>
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
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:46478 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765507AbXEUTWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 15:22:06 -0400
Content-Disposition: inline; filename=sky2-88e8056-allow.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.
---------------------

From: Stephen Hemminger <shemminger@linux-foundation.org>

It looks like the problems of Gigabyte 88E8056 are unique to that chip
motherboard and maybe fixable by EEPROM update.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>

---
 drivers/net/sky2.c |    3 ---
 1 file changed, 3 deletions(-)

--- linux-2.6.21.1.orig/drivers/net/sky2.c
+++ linux-2.6.21.1/drivers/net/sky2.c
@@ -123,10 +123,7 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) }, /* 88E8050 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) }, /* 88E8053 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) }, /* 88E8055 */
-#ifdef broken
-	/* This device causes data corruption problems that are not resolved */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4364) }, /* 88E8056 */
-#endif
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) }, /* 88EC036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) }, /* 88EC032 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */

-- 
