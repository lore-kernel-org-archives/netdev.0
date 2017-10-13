From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,0/3] Add init of send table and var renames
Date: Fri, 13 Oct 2017 12:28:02 -0700
Message-ID: <20171013192805.18183-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

Add initialization of send indirection table. Otherwise it may contain
old info of previous device with different number of channels.

Also, did some variable renaming for easier reading.

Haiyang Zhang (3):
  hv_netvsc: Rename ind_table to rx_table
  hv_netvsc: Rename tx_send_table to tx_table
  hv_netvsc: Add initialization of tx_table in netvsc_device_add()

 drivers/net/hyperv/hyperv_net.h   | 4 ++--
 drivers/net/hyperv/netvsc.c       | 5 ++++-
 drivers/net/hyperv/netvsc_drv.c   | 8 ++++----
 drivers/net/hyperv/rndis_filter.c | 6 +++---
 4 files changed, 13 insertions(+), 10 deletions(-)

-- 
2.14.1
