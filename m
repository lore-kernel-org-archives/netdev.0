From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net 0/5] qlcnic: Bug fixes.
Date: Tue, 10 Dec 2013 12:33:00 -0500
Message-ID: <cover.1386648865.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:23023 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755421Ab3LJSFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 13:05:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

This series contains bug fixes for multi Tx queue implementation for 
all adapters.

Please apply to net.

Thanks,
Himanshu

Himanshu Madhani (4):
  qlcnic: use correct netif api to enable tx queues.
  qlcnic: fix diagnostic test for all supported adapters.
  qlcnic: Fix Tx/SDS ring validation logic.
  qlcnic: Fix TSS/RSS validation for 83xx/84xx series adapter.

Shahed Shaikh (1):
  qlcnic: Use spinlock per transmit queue

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h           |  3 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c |  4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c   | 19 ++++++++-----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c      |  3 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c        |  6 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |  6 ++----
 6 files changed, 20 insertions(+), 21 deletions(-)

-- 
1.8.1.4
