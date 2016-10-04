From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 00/13] fsl/fman: cleanup and small fixes
Date: Tue, 4 Oct 2016 10:30:24 +0300
Message-ID: <1475566237-4948-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxdev.baldrick@gmail.com, Madalin Bucur <madalin.bucur@nxp.com>,
 linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
 linux-kernel@vger.kernel.org
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

This series contains fixes for the DPAA FMan driver.
Adding myself as maintainer of the driver.

The following are changes since commit a4cc96d1f0170b779c32c6b2cc58764f5d2cdef0
 net: phy: Add Edge-rate driver for Microsemi PHYs.
and are available on the fman-next branch in the git repository at
 git://git.freescale.com/ppc/upstream/linux.git

Igal Liberman (1):
  fsl/fman: fix loadable module compilation

Madalin Bucur (12):
  fsl/fman: split lines over 80 characters
  fsl/fman: small fixes
  fsl/fman: use of_get_phy_mode()
  fsl/fman: simplify device tree reads
  fsl/fman: return a phy_dev pointer from init
  fsl/fman: MEMAC may use QSGMII PHY interface mode
  fsl/fman: check pcsphy pointer before use
  fsl/fman: check of_get_phy_mode() return value
  fsl/fman: simplify redundant condition
  fsl/fman: fix return value checking
  fsl/fman: remove leftover comment
  MAINTAINERS: net: add entry for Freescale QorIQ DPAA FMan driver

 MAINTAINERS                                      |  7 ++
 drivers/net/ethernet/freescale/fman/Makefile     | 10 +--
 drivers/net/ethernet/freescale/fman/fman.c       | 78 ++++++++++++++--------
 drivers/net/ethernet/freescale/fman/fman_mac.h   |  4 --
 drivers/net/ethernet/freescale/fman/fman_memac.c |  6 +-
 drivers/net/ethernet/freescale/fman/fman_muram.c |  3 +-
 drivers/net/ethernet/freescale/fman/fman_muram.h |  3 +-
 drivers/net/ethernet/freescale/fman/fman_port.c  | 55 ++++++++++------
 drivers/net/ethernet/freescale/fman/fman_sp.c    |  3 +
 drivers/net/ethernet/freescale/fman/mac.c        | 83 ++++++++----------------
 drivers/net/ethernet/freescale/fman/mac.h        |  3 +-
 11 files changed, 139 insertions(+), 116 deletions(-)

-- 
2.1.0
