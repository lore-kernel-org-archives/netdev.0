From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] DOC: Update networking/multiqueue.txt with correct
	information.
Date: Fri, 07 Sep 2007 15:50:12 -0700
Message-ID: <20070907225012.14742.7522.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6189 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758AbXIGWuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 18:50:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updated the multiqueue.txt document to call out the correct kernel options
to select to enable multiqueue.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 Documentation/networking/multiqueue.txt |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/multiqueue.txt b/Documentation/networking/multiqueue.txt
index 00b60cc..ea5a42e 100644
--- a/Documentation/networking/multiqueue.txt
+++ b/Documentation/networking/multiqueue.txt
@@ -58,9 +58,13 @@ software, so it's a straight round-robin qdisc.  It uses the same syntax and
 classification priomap that sch_prio uses, so it should be intuitive to
 configure for people who've used sch_prio.
 
-The PRIO qdisc naturally plugs into a multiqueue device.  If PRIO has been
-built with NET_SCH_PRIO_MQ, then upon load, it will make sure the number of
-bands requested is equal to the number of queues on the hardware.  If they
+In order to utilitize the multiqueue features of the qdiscs, the network
+device layer needs to enable multiple queue support.  This can be done by
+selecting NETDEVICES_MULTIQUEUE under Drivers.
+
+The PRIO qdisc naturally plugs into a multiqueue device.  If
+NETDEVICES_MULTIQUEUE is selected, then on qdisc load, the number of
+bands requested is compared to the number of queues on the hardware.  If they
 are equal, it sets a one-to-one mapping up between the queues and bands.  If
 they're not equal, it will not load the qdisc.  This is the same behavior
 for RR.  Once the association is made, any skb that is classified will have
