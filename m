From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net v4 0/4] fsl/fman: fixes for ARM
Date: Mon, 19 Dec 2016 22:42:42 +0200
Message-ID: <1482180166-10677-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <scott.wood@nxp.com>, <mpe@ellerman.id.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0076.outbound.protection.outlook.com ([104.47.42.76]:50980
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755130AbcLSUmy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 15:42:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch set fixes advertised speeds for QSGMII interfaces, disables
A007273 erratum workaround on non-PowerPC platforms where it does not
apply, enables compilation on ARM64 and addresses a probing issue on
non PPC platforms.

Changes from v3: removed redundant comment, added ack by Scott
Changes from v2: merged fsl/fman changes to avoid a point of failure
Changes from v1: unifying probing on all supported platforms

Madalin Bucur (4):
  fsl/fman: fix 1G support for QSGMII interfaces
  powerpc: fsl/fman: remove fsl,fman from of_device_ids[]
  fsl/fman: A007273 only applies to PPC SoCs
  fsl/fman: enable compilation on ARM64

 arch/powerpc/platforms/85xx/corenet_generic.c |  3 ---
 drivers/net/ethernet/freescale/fman/Kconfig   |  2 +-
 drivers/net/ethernet/freescale/fman/fman.c    | 15 +++++++++++++++
 drivers/net/ethernet/freescale/fman/mac.c     |  1 +
 4 files changed, 17 insertions(+), 4 deletions(-)

-- 
2.1.0
