From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH 0/2] dpaa_eth: a couple of fixes
Date: Wed, 4 Jan 2017 13:21:28 +0200
Message-ID: <1483528890-8621-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linuxppc-dev@lists.ozlabs.org>,
        <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add cleanup on PHY initialization failure path, avoid using
uninitialized memory at CGR init.

Madalin Bucur (1):
  dpaa_eth: cleanup after init_phy() failure

Roy Pledge (1):
  dpaa_eth: Initialize CGR structure before init

 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

-- 
2.1.0
