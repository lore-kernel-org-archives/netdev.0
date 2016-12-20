From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Subject: [PATCH net-next 00/10] netcp: enhancements and minor fixes
Date: Tue, 20 Dec 2016 17:09:43 -0500
Message-ID: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <grygorii.strashko-l0cyMroinI0@public.gmane.org>, <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <mark.rutland-5wv7dgnIgG8@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series is for net-next. This propagates enhancements and minor
bug fixes from internal version of the driver to keep the upstream
in sync. Please review and apply if this looks good.

Tested on all of K2HK/E/L boards.

Thanks
Murali Karicheri

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

WingMan Kwok (2):
  net: netcp: ethss: add support of subsystem register region regmap
  net: netcp: ethss: add support of 10gbe pcsr link status

 .../devicetree/bindings/net/keystone-netcp.txt     |  19 +-
 drivers/net/ethernet/ti/cpsw_ale.c                 | 180 ++++++++++++++++---
 drivers/net/ethernet/ti/cpsw_ale.h                 |  17 +-
 drivers/net/ethernet/ti/netcp.h                    |  21 +++
 drivers/net/ethernet/ti/netcp_core.c               | 102 ++++++++---
 drivers/net/ethernet/ti/netcp_ethss.c              | 200 +++++++++++++++++----
 include/linux/soc/ti/knav_dma.h                    |   2 +
 7 files changed, 456 insertions(+), 85 deletions(-)

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
