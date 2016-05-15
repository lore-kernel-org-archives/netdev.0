From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 0/9] bnxt_en: updates for net-next.
Date: Sun, 15 May 2016 03:04:42 -0400
Message-ID: <1463295891-15216-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34292 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbcEOHFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 03:05:03 -0400
Received: by mail-pf0-f176.google.com with SMTP id y69so56133487pfb.1
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 00:05:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Non-critical bug fixes, improvements, a new ethtool feature, and a new
device ID.

v2: Fixed a bug in bnxt_get_module_eeprom() found by Ben Hutchings.

Ajit Khaparde (2):
  bnxt_en: Add Support for ETHTOOL_GMODULEINFO and ETHTOOL_GMODULEEEPRO
  bnxt_en: Report PCIe link speed and width during driver load

Michael Chan (6):
  bnxt_en: Reduce maximum ring pages if page size is 64K.
  bnxt_en: Improve the delay logic for firmware response.
  bnxt_en: Fix length value in dmesg log firmware error message.
  bnxt_en: Simplify and improve unsupported SFP+ module reporting.
  bnxt_en: Add BCM57314 device ID.
  bnxt_en: Use dma_rmb() instead of rmb().

Satish Baddipadige (1):
  bnxt_en: Fix invalid max channel parameter in ethtool -l.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 111 +++++++++++--------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  19 +++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 127 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     |  34 ++++++
 4 files changed, 242 insertions(+), 49 deletions(-)

-- 
1.8.3.1
