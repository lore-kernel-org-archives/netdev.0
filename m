From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 0/2] bnxt_en: Zero pad fw messages and add fw reset.
Date: Thu, 7 Jan 2016 19:56:56 -0500
Message-ID: <1452214618-15519-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:28237 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355AbcAHA5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 19:57:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2 patches related to firmware for net-next.

Michael Chan (2):
  bnxt_en: Zero pad firmware messages to 128 bytes.
  bnxt_en: Reset embedded processor after applying firmware upgrade

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  3 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 46 +++++++++++++++++++++--
 2 files changed, 45 insertions(+), 4 deletions(-)

-- 
1.8.3.1
