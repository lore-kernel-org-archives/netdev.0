From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net 0/3] dpaa_eth: a couple of fixes
Date: Thu, 15 Dec 2016 15:13:03 +0200
Message-ID: <1481807586-4798-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 davem@davemloft.net
To: <netdev@vger.kernel.org>
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

This patch set introduces big endian accessors in the dpaa_eth driver
making sure accesses to the QBMan HW are correct on little endian
platforms. Removing a redundant Kconfig dependency on FSL_SOC.
Adding myself as maintainer of the dpaa_eth driver.

Claudiu Manoil (1):
  dpaa_eth: use big endian accessors

Madalin Bucur (2):
  dpaa_eth: remove redundant dependency on FSL_SOC
  MAINTAINERS: net: add entry for Freescale QorIQ DPAA Ethernet driver

 MAINTAINERS                                    |  6 +++
 drivers/net/ethernet/freescale/dpaa/Kconfig    |  2 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 71 ++++++++++++++------------
 3 files changed, 44 insertions(+), 35 deletions(-)

-- 
2.1.0
