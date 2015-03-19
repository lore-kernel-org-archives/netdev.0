From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/2] Add Device ID and make device ID table const
Date: Thu, 19 Mar 2015 22:27:34 +0530
Message-ID: <1426784256-5689-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9644 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751202AbbCSQwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 12:52:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patch series adds new device ID and makes device ID table const 

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 and csiostor driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4: Add device ID for new adapter
  cxgb4/cxgb4vf/csiostor: Make PCI Device ID Tables be "const"

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h |    5 +----
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +-
 drivers/scsi/csiostor/csio_init.c                  |    2 +-
 4 files changed, 4 insertions(+), 7 deletions(-)
