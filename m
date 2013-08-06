From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 0/6 net-next] bnx2 EEH and WoL/PM patches
Date: Tue, 6 Aug 2013 15:50:06 -0700
Message-ID: <1375829412-26425-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4007 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756397Ab3HFW2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 18:28:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch fixes EEH/AER error path.  The rest of the patches
modernize the driver to use latest APIs for WoL and power management.

Michael Chan (6):
  bnx2: Handle error condition in ->slot_reset()
  bnx2: Use kernel APIs for WoL and power state changes.
  bnx2: Refactor WoL setup into a separate function.
  bnx2: Use SIMPLE_DEV_PM_OPS.
  bnx2: Add pci shutdown handler.
  bnx2: Update version to 2.2.4

 drivers/net/ethernet/broadcom/bnx2.c |  308 +++++++++++++++++-----------------
 drivers/net/ethernet/broadcom/bnx2.h |    2 +-
 2 files changed, 158 insertions(+), 152 deletions(-)
