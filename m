From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 0/5] qed*: Fixes series
Date: Sun, 19 Jun 2016 15:18:10 +0300
Message-ID: <1466338695-15538-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:48729 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751565AbcFSMS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 08:18:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains several small fixes to driver behavior
[4th patch is the only one containing a 'fatal' fix, but the error
is only theoretical for qede; if would require another protocol
driver yet unsubmitted to reach it].

Dave,

Please consider applying this to `net'.

Thanks,
Yuval

Yuval Mintz (5):
  qed: Correct default vlan behavior
  qed: Prevent VF from Tx-switching 'promisc'
  qed*: Don't reset statistics on inner reload
  qed: Fix returning unlimited SPQ entries
  qed: Add missing port-mode

 drivers/net/ethernet/qlogic/qed/qed_hsi.h    |  1 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c     |  8 +++-----
 drivers/net/ethernet/qlogic/qed/qed_main.c   |  1 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c    | 21 ++++++++++++++++++---
 drivers/net/ethernet/qlogic/qede/qede_main.c |  7 ++++---
 include/linux/qed/qed_eth_if.h               |  1 +
 6 files changed, 28 insertions(+), 11 deletions(-)

-- 
1.9.3
