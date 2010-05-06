From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/4] e1000e: Remove unnessary log message
Date: Wed, 05 May 2010 17:03:11 -0700
Message-ID: <20100506000309.8042.9387.stgit@localhost.localdomain>
References: <20100506000221.8042.64794.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Tom Herbert <therbert@google.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:57716
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752161Ab0EFAD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 20:03:29 -0400
In-Reply-To: <20100506000221.8042.64794.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>

Remove e_info message printed whenever TSO is enabled or disabled.
This is not very useful and just clutters dmesg.

Signed-off-by: Tom Herbert <therbert@google.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index c81118a..6ff376c 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -412,7 +412,6 @@ static int e1000_set_tso(struct net_device *netdev, u32 data)
 		netdev->features &= ~NETIF_F_TSO6;
 	}
 
-	e_info("TSO is %s\n", data ? "Enabled" : "Disabled");
 	adapter->flags |= FLAG_TSO_FORCE;
 	return 0;
 }

