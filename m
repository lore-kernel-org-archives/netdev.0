From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] mdio: Export mdio.h to userland
Date: Wed, 29 Feb 2012 19:02:02 +0000
Message-ID: <1330542122.5881.2.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27970 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S964992Ab2B2TCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 14:02:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ID packing/unpacking functions are needed by userland and the
register definitions may also be useful there.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/Kbuild |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index c94e717..4b0b7ed 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -238,6 +238,7 @@ header-y += magic.h
 header-y += major.h
 header-y += map_to_7segment.h
 header-y += matroxfb.h
+header-y += mdio.h
 header-y += media.h
 header-y += mempolicy.h
 header-y += meye.h
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
