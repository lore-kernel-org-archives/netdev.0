From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [net-next v1 0/8] netcp: enhancements and minor fixes
Date: Fri, 6 Jan 2017 15:37:38 -0500
Message-ID: <1483735066-14632-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <arnd@arndb.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <mugunthanvnm@ti.com>,
        <linux-omap@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is for net-next. This propagates enhancements and minor
bug fixes from internal version of the driver to keep the upstream
in sync. Please review and apply if this looks good.

Tested on all of K2HK/E/L boards with nfs rootfs.
Test logs below
K2HK-EVM: http://pastebin.ubuntu.com/23754106/
k2L-EVM: http://pastebin.ubuntu.com/23754143/
K2E-EVM: http://pastebin.ubuntu.com/23754159/

History:
  v1 - dropped 1/10 amd 2/10 of v0 based on comments from Rob as
       it needs more work before submission
  v0 - Initial version

Michael Scherban (1):
  net: netcp: store network statistics in 64 bits

Murali Karicheri (7):
  net: netcp: extract eflag from desc for rx_hook handling
  net: netcp: remove the redundant memmov()
  net: netcp: ethss: get phy-handle only if link interface is MAC-to-PHY
  net: netcp: use hw capability to remove FCS word from rx packets
  net: netcp: ale: update to support unknown vlan controls for NU switch
  net: netcp: ale: use ale_status to size the ale table
  net: netcp: ale: add proper ale entry mask bits for netcp switch ALE

 drivers/net/ethernet/ti/cpsw_ale.c    | 180 +++++++++++++++++++++++++++++-----
 drivers/net/ethernet/ti/cpsw_ale.h    |  17 +++-
 drivers/net/ethernet/ti/netcp.h       |  21 ++++
 drivers/net/ethernet/ti/netcp_core.c  | 102 +++++++++++++++----
 drivers/net/ethernet/ti/netcp_ethss.c |  23 +++--
 include/linux/soc/ti/knav_dma.h       |   2 +
 6 files changed, 292 insertions(+), 53 deletions(-)

-- 
1.9.1
