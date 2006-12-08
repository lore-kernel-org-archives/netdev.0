From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 17/22] e1000: set max frame size before enabling new link settings
Date: Fri, 08 Dec 2006 15:03:22 -0800
Message-ID: <20061208230322.30109.58025.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4393 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761264AbWLHWxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:53:55 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index cb6b732..34ceff1 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3584,12 +3584,11 @@ e1000_change_mtu(struct net_device *netd
 		adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 
 	netdev->mtu = new_mtu;
+	adapter->hw.max_frame_size = max_frame;
 
 	if (netif_running(netdev))
 		e1000_reinit_locked(adapter);
 
-	adapter->hw.max_frame_size = max_frame;
-
 	return 0;
 }
 



---
Auke Kok <auke-jan.h.kok@intel.com>
