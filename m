From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 00/10] bnxt_en: updates for net-next.
Date: Thu, 25 Feb 2016 03:19:24 -0500
Message-ID: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:41088
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759164AbcBYITf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 03:19:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miscellaneous updates covering SRIOV, IRQ coalescing, firmware logging and
package version for net-next.  Thanks. 

Jeffrey Huang (2):
  bnxt_en: Improve bnxt_vf_update_mac().
  bnxt_en: Send PF driver unload notification to all VFs.

Michael Chan (8):
  bnxt_en: Store irq coalescing timer values in micro seconds.
  bnxt_en: Refactor bnxt_hwrm_set_coal().
  bnxt_en: Add coalescing support for tx rings.
  bnxt_en: Use firmware provided message timeout value.
  bnxt_en: Fix dmesg log firmware error messages.
  bnxt_en: Add installed-package firmware version reporting via Ethtool
    GDRVINFO
  bnxt_en: Refactor _hwrm_send_message().
  bnxt_en: Add hwrm_send_message_silent().

 drivers/net/ethernet/broadcom/bnxt/bnxt.c          | 166 ++++++++++++++-------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h          |  35 ++---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c  | 126 ++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h |  14 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c    |  56 ++++++-
 5 files changed, 306 insertions(+), 91 deletions(-)

-- 
1.8.3.1
