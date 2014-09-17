From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/3] bnx2x: Support new Multi-function modes
Date: Wed, 17 Sep 2014 16:24:35 +0300
Message-ID: <1410960278-32064-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:24562 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754831AbaIQNYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 09:24:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for 2 new Multi-function modes -
Unified Fabric Port [UFP] as well as nic partitioning 1.5 [NPAR1.5].

With the addition of the new multi-function modes, the series also
revises some of the storage-related multi-function macros.

[Do notice this series has several small issues with checkpatch]

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Dmitry Kravkov (1):
  bnx2x: Changes with storage & MAC macros

Yuval Mintz (2):
  bnx2x: New multi-function mode: UFP
  bnx2x: Add a fallback multi-function mode NPAR1.5

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  53 +++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  12 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |  14 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h    |  28 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   | 204 ++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |  41 ++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     |  23 +++
 8 files changed, 296 insertions(+), 81 deletions(-)

-- 
1.8.3.1
