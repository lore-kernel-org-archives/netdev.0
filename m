From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH 0/3] can: m_can: Add PM Runtime Support
Date: Wed, 19 Jul 2017 18:09:23 -0500
Message-ID: <20170719230926.10872-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add PM runtime support to the MCAN driver. To support devices that don't use
PM runtime leave the original clk calls in the driver. Perhaps in the future
when it makes sense we can remove these non pm runtime clk calls.

Franklin S Cooper Jr (3):
  can: m_can: Make hclk optional
  can: m_can: Update documentation to indicate that hclk may be optional
  can: m_can: Add PM Runtime

 .../devicetree/bindings/net/can/m_can.txt          |  3 ++-
 drivers/net/can/m_can/m_can.c                      | 22 ++++++++++++++++++++--
 2 files changed, 22 insertions(+), 3 deletions(-)

-- 
2.10.0
