From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 0/2] cxgb4 FW macro changes for new FW
Date: Wed,  1 Apr 2015 21:41:14 +0530
Message-ID: <1427904676-31000-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11554 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752167AbbDAK7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:59:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Fix to dump device log even in the case of firmware crash. Also
incorporates changes for new FW.

This patch series has been created against net tree and includes patches on
cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4: Firmware macro changes for fw verison 1.13.32.0
  cxgb4: Fix to dump devlog, even if FW is crashed

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h        |  2 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c   | 33 +++-----------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c        | 53 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h      |  3 ++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h     | 39 ++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h |  8 ++--
 6 files changed, 106 insertions(+), 32 deletions(-)

-- 
2.3.4
