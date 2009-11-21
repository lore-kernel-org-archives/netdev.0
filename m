From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 15/23] e1000e: provide comment for 82571
	workaround
Date: Sat, 21 Nov 2009 01:26:24 -0800
Message-ID: <20091121092623.5715.76622.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:39106
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750832AbZKUJ0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:26:35 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 7cdf176..0e8aa34 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1114,6 +1114,13 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 		reg |= (1 << 22);
 		ew32(GCR, reg);
 
+		/*
+		 * Workaround for hardware errata.
+		 * apply workaround for hardware errata documented in errata
+		 * docs Fixes issue where some error prone or unreliable PCIe
+		 * completions are occurring, particularly with ASPM enabled.
+		 * Without fix, issue can cause tx timeouts.
+		 */
 		reg = er32(GCR2);
 		reg |= 1;
 		ew32(GCR2, reg);

