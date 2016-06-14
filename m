From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/3] Add SRIOV configuration via sysfs and few fixes
Date: Tue, 14 Jun 2016 14:39:29 +0530
Message-ID: <1465895372-21101-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:49597 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751701AbcFNJEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 05:04:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series adds support to configure SR-IOV via PCI sysfs interface,
reduces resource allocation in kdump kernel by disabling offload. Also
synchronize unicast and multicast mac address, even in the interface is in
Promiscuous mode.

This patch series has been created against net-next tree and includes
patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks


Hariprasad Shenai (3):
  cxgb4: Force cxgb4 driver as MASTER in kdump kernel
  cxgb4: Enable SR-IOV configuration via PCI sysfs interface
  cxgb4/cxgb4vf: Synchronize all MAC addresses

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 82 +++++++++++++++++++---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  8 +--
 2 files changed, 76 insertions(+), 14 deletions(-)

-- 
2.3.4
