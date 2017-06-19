From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH 0/2] fix loadable module for DPAA Ethernet
Date: Mon, 19 Jun 2017 18:04:15 +0300
Message-ID: <1497884657-3744-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 Madalin Bucur <madalin.bucur@nxp.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

The DPAA Ethernet makes use of a symbol that is not exported.
Address the issue by propagating the dma_ops rather than calling
arch_setup_dma_ops().

Madalin Bucur (2):
  fsl/fman: propagate dma_ops
  dpaa_eth: reuse the dma_ops provided by the FMan MAC device

 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 2 +-
 drivers/net/ethernet/freescale/fman/mac.c      | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

-- 
2.1.0
