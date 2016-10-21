From: <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 0/7] qed*: fix series.
Date: Fri, 21 Oct 2016 04:43:38 -0400
Message-ID: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@cavium.com>,
        <Yuval.Mintz@cavium.com>, <manish.chopra@cavium.com>,
        Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49026 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932616AbcJUJ3r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 05:29:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

The patch series contains several minor bug fixes for qed/qede modules.
Please consider applying this to 'net' branch.

Manish Chopra (1):
  qede: Fix incorrrect usage of APIs for un-mapping DMA memory

Sudarsana Reddy Kalluru (6):
  qede: get_channels() need to populate max tx/rx coalesce values
  qede: Do not allow RSS config for 100G devices
  qede: Loopback implementation should ignore the normal traffic
  qed*: Reduce the memory footprint for Rx path
  qede: Reconfigure rss indirection direction table when rss count is
    updated
  qed: Zero-out the buffer paased to dcbx_query() API

 drivers/net/ethernet/qlogic/qed/qed_dcbx.c      |  2 +
 drivers/net/ethernet/qlogic/qed/qed_main.c      |  1 +
 drivers/net/ethernet/qlogic/qede/qede.h         |  3 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 99 ++++++++++++++++---------
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 11 ++-
 include/linux/qed/qed_if.h                      |  1 +
 6 files changed, 75 insertions(+), 42 deletions(-)

-- 
1.8.3.1
