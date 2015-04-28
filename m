From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next v1 0/4] drivers: net: xgene: Add ethernet with ring manager v2 support
Date: Tue, 28 Apr 2015 13:52:36 -0700
Message-ID: <1430254360-23698-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, kchudgar@apm.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og103.obsmtp.com ([64.18.0.145]:49799 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965992AbbD1UrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 16:47:13 -0400
Received: by pdbqa5 with SMTP id qa5so6545194pdb.1
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:47:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding XFI based 10GbE and SGMII based 1GbE with ring manager v2 support
for APM X-Gene ethernet driver.  The ring manager v2 is used by 2nd
generation SoC.

v1:
* Initial version
---

Iyappan Subramanian (4):
  drivers: net: xgene: Change ring manager to use function pointers
  drivers: net: xgene: Add ring manager v2 functions
  drivers: net: xgene: Add 10GbE support with ring manager v2
  drivers: net: xgene: Add SGMII based 1GbE support with ring manager v2

 drivers/net/ethernet/apm/xgene/Makefile           |   2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    |  36 +++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |   8 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 205 ++++++++++++++++------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  28 +++
 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c | 200 +++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.h |  49 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c |  62 +++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |   1 -
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h |  20 +++
 10 files changed, 530 insertions(+), 81 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.h

-- 
1.9.1
