From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 0/3] qed: Bandwidth configuration support
Date: Tue, 26 Apr 2016 10:56:07 -0400
Message-ID: <1461682570-745-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:57834 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752544AbcDZPiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 11:38:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This series adds support in driver for min/max bandwidth configuration
for the PF on the link change notification or on explicit request of
bandwidth update from the MFW [management firmware].

The same infrastructure would later be used by user based flows
[for example, rate shaping for the VFs]

Please consider applying this series to "net-next"

Thanks,
Manish

Manish Chopra (3):
  qed: Add vport WFQ configuration APIs
  qed: Add PF max bandwidth configuration support
  qed: Add PF min bandwidth configuration support

 drivers/net/ethernet/qlogic/qed/qed.h              |  11 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c          | 327 ++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h          |   6 +-
 .../net/ethernet/qlogic/qed/qed_init_fw_funcs.c    |  40 +++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c          | 146 +++++----
 drivers/net/ethernet/qlogic/qed/qed_mcp.h          |  21 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h     |   2 +
 7 files changed, 491 insertions(+), 62 deletions(-)

-- 
2.7.2
