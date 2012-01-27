From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/32] sfc: Remove unnecessary inclusion of
 <asm/io.h>, prompted by checkpatch
Date: Fri, 27 Jan 2012 20:43:25 +0000
Message-ID: <1327697005.2503.12.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63497 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752649Ab2A0Un3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:43:29 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the warning:

WARNING: Use #include <linux/io.h> instead of <asm/io.h>

There is no need for selftest.c to include the file at all.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/selftest.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index 17ff9b3..5226d98 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -19,7 +19,6 @@
 #include <linux/udp.h>
 #include <linux/rtnetlink.h>
 #include <linux/slab.h>
-#include <asm/io.h>
 #include "net_driver.h"
 #include "efx.h"
 #include "nic.h"
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
