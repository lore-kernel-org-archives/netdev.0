From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 0/2] net/hyperv: Add support for vlan trunking from guests
Date: Mon, 12 Mar 2012 13:20:48 -0700
Message-ID: <1331583650-29686-1-git-send-email-haiyangz@microsoft.com>
To: haiyangz@microsoft.com, kys@microsoft.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series add vlan trunking feature from guests. With this feature,
a Linux guest can now configure multiple vlans through a single synthetic
NIC on Win8 Hyper-V host.

Note: Both patches should go to the 'net-next' tree. The patch [1/2] is
required by the vlan trunking feature [2/2]. So they should go together.

The bug in rndis_filter_receive() does NOT happen until we start to use 
'per-packet-data' by the vlan trunking feature, so the bug fix [1/2] isn't
urgent to be applied into 'net' tree.


Haiyang Zhang (2):
  net/hyperv: Fix data corruption in rndis_filter_receive()
  net/hyperv: Add support for vlan trunking from guests

 drivers/net/hyperv/hyperv_net.h   |   34 +++++++++++++-
 drivers/net/hyperv/netvsc.c       |    3 +-
 drivers/net/hyperv/netvsc_drv.c   |    8 ++-
 drivers/net/hyperv/rndis_filter.c |   93 +++++++++++++++++++++++++++----------
 4 files changed, 110 insertions(+), 28 deletions(-)

-- 
1.7.4.1
