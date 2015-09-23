From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH 0/7] net: netcp: a set of bug fixes
Date: Wed, 23 Sep 2015 13:37:04 -0400
Message-ID: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nsekhar@ti.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<w-kwok2@ti.com>, <davem@davemloft.net>,
	<gregkh@linuxfoundation.org>, <stable@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series fixes a set of issues in netcp driver seen during internal
testing of the driver. While at it, do some clean up as well.

The fixes are tested on K2HK, K2L and K2E EVMs and the boot up logs can be
seen at

 http://pastebin.ubuntu.com/12533100/

Murali Karicheri (6):
  net: netcp: remove dead code from the driver
  net: netcp: move netcp_register_interface() to after attach module
  net: netcp: add error check to netcp_allocate_rx_buf()
  net: netcp: check for interface handle in netcp_module_probe()
  net: netcp: allocate buffers to desc before re-enable interrupt
  net: netcp: fix deadlock reported by lockup detector

WingMan Kwok (1):
  net: netcp: ethss: fix error in calling sgmii api with incorrect
    offset

 drivers/net/ethernet/ti/netcp_core.c  | 74 +++++++++++++++++------------------
 drivers/net/ethernet/ti/netcp_ethss.c | 47 ++++++++++------------
 2 files changed, 55 insertions(+), 66 deletions(-)

-- 
1.9.1
