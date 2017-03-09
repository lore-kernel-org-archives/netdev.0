From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next v2 00/10] QorIQ DPAA 1 updates
Date: Thu, 9 Mar 2017 16:36:55 +0200
Message-ID: <1489070225-7891-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: Madalin Bucur <madalin.bucur@nxp.com>, linux-kernel@vger.kernel.org,
 camelia.groza@nxp.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
 dan.carpenter@oracle.com
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

This patch set introduces a series of fixes and features to the DPAA 1
drivers. Besides activating hardware Rx checksum offloading, four traffic
classes are added for Tx traffic prioritisation.

The changes are also available on the dpaa_eth-next branch in the git
repository at:

  git://git.freescale.com/ppc/upstream/linux.git

changes from v1: added patch to enable context-A stashing

Camelia Groza (2):
  dpaa_eth: add four prioritised Tx traffic classes
  dpaa_eth: enable multiple Tx traffic classes

Madalin Bucur (8):
  fsl/fman: parse result data is big endian
  fsl/fman: set HW parser as BMI next engine
  fsl/fman: remove wrong free
  fsl/fman: enlarge FIFO to allow for the 5th port
  dpaa_eth: remove redundant initialization
  dpaa_eth: enable Rx checksum offload
  dpaa_eth: do not ignore port api return value
  dpaa_eth: enable context-A stashing

 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c  | 178 +++++++++++++++++++-----
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h  |   8 +-
 drivers/net/ethernet/freescale/fman/fman.c      |  23 ++-
 drivers/net/ethernet/freescale/fman/fman.h      |  10 +-
 drivers/net/ethernet/freescale/fman/fman_port.c |  76 +++++++++-
 5 files changed, 248 insertions(+), 47 deletions(-)

-- 
2.1.0
