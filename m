From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v1 0/2] drivers: net: xgene: Add TSO support
Date: Mon, 17 Aug 2015 14:33:03 -0700
Message-ID: <1439847185-22046-1-git-send-email-isubramanian@apm.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	kchudgar@apm.com, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34723 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbHQVdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:33:25 -0400
Received: by pdbfa8 with SMTP id fa8so59847767pdb.1
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:33:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding TSO support

iperf Tx data rate without TSO: 3.42 Gbps
                      with TSO: 9.41 Gbps

v1
* Initial version

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

Iyappan Subramanian (2):
  drivers: net: xgene: Preparatory patch for TSO support
  drivers: net: xgene: Adding support for TSO

 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  16 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 260 ++++++++++++++++++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  12 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |   8 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h |   2 +
 5 files changed, 272 insertions(+), 26 deletions(-)

-- 
1.9.1
