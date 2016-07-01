From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 00/11] bnxt_en updates for net-next.
Date: Fri,  1 Jul 2016 18:46:18 -0400
Message-ID: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36273 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418AbcGAWqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:43 -0400
Received: by mail-pf0-f178.google.com with SMTP id t190so43955492pfb.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mostly small miscellaneous changes.

Please review for net-next.  Thanks.

Michael Chan (7):
  bnxt_en: VF/NPAR should return -EOPNOTSUPP for unsupported ethtool
    ops.
  bnxt_en: Update firmware spec. to 1.3.0.
  bnxt_en: Do function reset on the 1st PF open only.
  bnxt_en: Enable MRU enables bit when configuring VNIC MRU.
  bnxt_en: Allow promiscuous mode for VF if default VLAN is enabled.
  bnxt_en: Assign netdev->dev_port with port ID.
  bnxt_en: Allow statistics DMA to be configurable using ethtool -C.

Rob Swindell (3):
  bnxt_en: Add support for updating flash more securely
  bnxt_en: Request firmware reset after successful firwmare update
  bnxt_en: Add support for firmware updates for additional processors.

Vasundhara Volam (1):
  bnxt_en: Increase maximum supported MTU to 9500.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c          | 47 +++++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h          | 17 +++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c  | 54 ++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h   |  1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h      | 87 +++++++++++++++-------
 drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h |  1 +
 6 files changed, 158 insertions(+), 49 deletions(-)

-- 
1.8.3.1
