From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 0/8] qed*: Bug fixes
Date: Thu, 26 May 2016 11:01:16 +0300
Message-ID: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60323 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753202AbcEZIBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 04:01:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contain several small fixes, most of which deal with
either 100g support, sriov or bandwidth configurations.

Dave,

Please consider applying this to `net'.

Thanks,
Yuval

Sudarsana Reddy Kalluru (2):
  qed: Fix allocation in interrupt context
  qed: Prevent 100g from working in MSI

Yuval Mintz (6):
  qede: Fix VF minimum BW setting
  qede: Reload on GRO changes
  qede: Don't expose self-test for VFs
  qed: Save min/max accross dcbx-change
  qed: Add missing 100g init mode
  qed: Don't config min BW on 100g on link flap

 drivers/net/ethernet/qlogic/qed/qed_dev.c       | 52 ++++++++++++++++++-------
 drivers/net/ethernet/qlogic/qed/qed_main.c      | 18 +++++----
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  5 ++-
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 26 ++++++++++++-
 4 files changed, 78 insertions(+), 23 deletions(-)

-- 
1.9.3
