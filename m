From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 0/6] qed*: Small fixes series
Date: Wed, 27 Jul 2016 14:45:18 +0300
Message-ID: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59980 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752930AbcG0Lpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 07:45:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This contains several small [and straight-forward] fixes to qed*
drivers.

Please consider applying this to `net'.

Thanks,
Yuval

Yuval Mintz (6):
  qede: Don't try removing unconfigured vlans
  qed: Fix removal of spoof checking for VFs
  qed: Don't over-do producer cleanup for Rx
  qede: Reset statistics on explicit down
  qed: Correct min bandwidth for 100g
  qed: Prevent over-usage of vlan credits by PF

 drivers/net/ethernet/qlogic/qed/qed_dev.c    |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c     | 13 ++++++++++---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c  |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.c     |  4 ++--
 drivers/net/ethernet/qlogic/qede/qede_main.c | 12 ++++++++----
 5 files changed, 22 insertions(+), 11 deletions(-)

-- 
1.9.3
