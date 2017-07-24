From: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v2 0/3] can: m_can: Add PM Runtime Support
Date: Mon, 24 Jul 2017 17:51:39 -0500
Message-ID: <20170724225142.19975-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add PM runtime support to the MCAN driver. To support devices that don't
use PM runtime leave the original clk calls in the driver. Perhaps in the
future when it makes sense we can remove these non pm runtime clk calls.

Version 2 changes:
Used NULL instead of 0 for unused hclk handle

Franklin S Cooper Jr (3):
  can: m_can: Make hclk optional
  can: m_can: Update documentation to indicate that hclk may be optional
  can: m_can: Add PM Runtime

 .../devicetree/bindings/net/can/m_can.txt          |  3 ++-
 drivers/net/can/m_can/m_can.c                      | 22 ++++++++++++++++++++--
 2 files changed, 22 insertions(+), 3 deletions(-)

-- 
2.10.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
