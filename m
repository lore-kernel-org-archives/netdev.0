From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,0/3] hv_netvsc: support changing TCP hash level
Date: Fri,  6 Oct 2017 08:33:56 -0700
Message-ID: <20171006153359.8400-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

The patch set simplifies the existing hash level switching code for
UDP. It also adds the support for changing TCP hash level. So users
can switch between L3 an L4 hash levels for TCP and UDP.

Haiyang Zhang (3):
  hv_netvsc: Change the hash level variable to bit flags
  hv_netvsc: Add ethtool handler to set and get TCP hash levels
  hv_netvsc: Update netvsc Document for TCP hash level setting

 Documentation/networking/netvsc.txt |  8 ++--
 drivers/net/hyperv/hyperv_net.h     | 11 ++++-
 drivers/net/hyperv/netvsc_drv.c     | 96 ++++++++++++++++++++++++++++---------
 3 files changed, 86 insertions(+), 29 deletions(-)

-- 
2.14.1
