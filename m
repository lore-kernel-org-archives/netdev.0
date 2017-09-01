From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next, 0/4] cleanups and fixes of channel settings
Date: Fri,  1 Sep 2017 14:30:03 -0700
Message-ID: <20170901213007.10325-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

This patch set cleans up some unused variables, unnecessary checks.
Also fixed some limit checking of channel number.


Haiyang Zhang (4):
  hv_netvsc: Clean up an unused parameter in rndis_filter_set_rss_param()
  hv_netvsc: Simplify num_chn checking in rndis_filter_device_add()
  hv_netvsc: Simplify the limit check in netvsc_set_channels()
  hv_netvsc: Fix the channel limit in netvsc_set_rxfh()

 drivers/net/hyperv/hyperv_net.h   |  2 +-
 drivers/net/hyperv/netvsc_drv.c   |  7 ++-----
 drivers/net/hyperv/rndis_filter.c | 11 +++++------
 3 files changed, 8 insertions(+), 12 deletions(-)

-- 
2.14.1
