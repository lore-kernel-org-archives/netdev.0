From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net 0/4] fsl/fman: fixes for ARM
Date: Thu, 15 Dec 2016 15:11:33 +0200
Message-ID: <1481807497-4724-1-git-send-email-madalin.bucur@nxp.com>
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

The patch set fixes advertised speeds for QSGMII interfaces, disables
A007273 erratum workaround on non-PowerPC platforms where it does not
apply, enables compilation on ARM64 and addresses a probing issue on
ARM64.

Igal Liberman (1):
  fsl/fman: arm: call of_platform_populate() for arm64 platfrom

Madalin Bucur (3):
  fsl/fman: fix 1G support for QSGMII interfaces
  fsl/fman: A007273 only applies to PPC SoCs
  fsl/fman: enable compilation on ARM64

 drivers/net/ethernet/freescale/fman/Kconfig |  2 +-
 drivers/net/ethernet/freescale/fman/fman.c  | 18 ++++++++++++++++++
 drivers/net/ethernet/freescale/fman/mac.c   |  1 +
 3 files changed, 20 insertions(+), 1 deletion(-)

-- 
2.1.0
