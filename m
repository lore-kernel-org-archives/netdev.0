From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/5] qed: IOV enhncements and fixups
Date: Sun, 15 May 2016 14:48:04 +0300
Message-ID: <1463312889-19351-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:59505 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752420AbcEOLsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 07:48:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This is a follow-up on the recent patch series that adds SR-IOV support
to qed. All content here is iov-related fixups [nothing terminal] and
enhancements.

Please consider applying this series to `net-next'.

Thanks,
Yuval

Manish Chopra (1):
  qed: Reset link on IOV disable

Yuval Mintz (4):
  qed: Correct PF-sanity check
  qed: Improve VF interrupt reset
  qed: Allow more than 16 VFs
  qed: VFs gracefully accept lack of PM

 drivers/net/ethernet/qlogic/qed/qed_int.c      |  59 ++++++------
 drivers/net/ethernet/qlogic/qed/qed_int.h      |  20 +----
 drivers/net/ethernet/qlogic/qed/qed_main.c     |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   2 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c    | 119 +++++++++++++------------
 5 files changed, 99 insertions(+), 103 deletions(-)

-- 
1.9.3
