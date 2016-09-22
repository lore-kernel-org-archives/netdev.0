From: sthemmin@exchange.microsoft.com
Subject: [PATCH net-next 0/7] hv_netvsc changes
Date: Thu, 22 Sep 2016 16:56:28 -0700
Message-ID: <1474588595-16054-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net ([208.109.80.60]:59852
        "EHLO p3plsmtps2ded03.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757860AbcIVWGI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 18:06:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

These are mostly about improving the handling of interaction between
the virtual network device (netvsc) and the SR-IOV VF network device.

Stephen Hemminger (7):
  hv_netvsc: use consume_skb
  hv_netvsc: dev hold/put reference to VF
  hv_netvsc: simplify callback event code
  hv_netvsc: improve VF device matching
  hv_netvsc: use RCU to protect vf_netdev
  hv_netvsc: remove VF in flight counters
  hv_netvsc: count multicast packets received

 drivers/net/hyperv/hyperv_net.h |    7 +-
 drivers/net/hyperv/netvsc.c     |    4 +-
 drivers/net/hyperv/netvsc_drv.c |  188 +++++++++++++++++---------------------
 3 files changed, 90 insertions(+), 109 deletions(-)

-- 
1.7.4.1
