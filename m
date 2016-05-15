From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/9] bnxt_en: updates for net-next.
Date: Sat, 14 May 2016 20:29:39 -0400
Message-ID: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36681 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965AbcEOA37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 20:29:59 -0400
Received: by mail-pf0-f178.google.com with SMTP id c189so56579311pfb.3
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 17:29:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Non-critical bug fixes, improvements, a new ethtool feature, and a new
device ID.

Michael Chan (9):
  bnxt_en: Fix invalid max channel parameter in ethtool -l.
  bnxt_en: Add Support for ETHTOOL_GMODULEINFO and ETHTOOL_GMODULEEEPRO
  bnxt_en: Report PCIe link speed and width during driver load
  bnxt_en: Reduce maximum ring pages if page size is 64K.
  bnxt_en: Improve the delay logic for firmware response.
  bnxt_en: Fix length value in dmesg log firmware error message.
  bnxt_en: Simplify and improve unsupported SFP+ module reporting.
  bnxt_en: Add BCM57314 device ID.
  bnxt_en: Use dma_rmb() instead of rmb().

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 111 +++++++++++--------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  19 +++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 126 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     |  34 ++++++
 4 files changed, 241 insertions(+), 49 deletions(-)

-- 
1.8.3.1
