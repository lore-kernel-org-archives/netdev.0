From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] e1000: cleanup unused parameters
Date: Thu, 13 May 2010 18:25:56 -0700
Message-ID: <20100514012554.30457.66528.stgit@localhost.localdomain>
References: <20100514012425.30457.23799.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:40790
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755107Ab0ENB0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 21:26:15 -0400
In-Reply-To: <20100514012425.30457.23799.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

During the cleanup pass after the removal of e1000e hardware from e1000 some
parameters were missed.  Remove them because it is just dead code.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_param.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index 9fbb562..10d8d98 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -188,14 +188,6 @@ E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
  */
 E1000_PARAM(SmartPowerDownEnable, "Enable PHY smart power down");
 
-/* Enable Kumeran Lock Loss workaround
- *
- * Valid Range: 0, 1
- *
- * Default Value: 1 (enabled)
- */
-E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
-
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
 	const char *name;

