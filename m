From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/6] doc, net: Remove obsolete reference to
 dev->poll
Date: Fri, 6 Apr 2012 01:39:10 +0100
Message-ID: <1333672750.2652.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28069 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752951Ab2DFAjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 20:39:14 -0400
In-Reply-To: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit bea3348eef27e6044b6161fd04c3152215f96411 ('[NET]: Make NAPI
polling independent of struct net_device objects.') removed the
automatic disabling of NAPI polling by dev_close(), and drivers
must now do this themselves.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 Documentation/networking/netdevices.txt |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/netdevices.txt b/Documentation/networking/netdevices.txt
index 8935834..336fe8e 100644
--- a/Documentation/networking/netdevices.txt
+++ b/Documentation/networking/netdevices.txt
@@ -54,8 +54,7 @@ dev->open:
 dev->stop:
 	Synchronization: rtnl_lock() semaphore.
 	Context: process
-	Note1: netif_running() is guaranteed false
-	Note2: dev->poll() is guaranteed to be stopped
+	Note: netif_running() is guaranteed false
 
 dev->do_ioctl:
 	Synchronization: rtnl_lock() semaphore.
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
