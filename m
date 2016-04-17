From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/5] qed*: eeprom access et al.
Date: Sun, 17 Apr 2016 22:26:30 +0300
Message-ID: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:3722 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750854AbcDQT0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 15:26:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series contains some ethtool-related enhancements,
where the significant addition is the ability to read/write from
the device's non-volatile memory via the ethtool socket
[required for the adapter's fw-upgrade utility].

Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval

P.s. - up until this point I've tried to maintain distinct patches for
qed and qede. But where the infrastructure is either scarce or else
encompass most of the changes [as in with the eeprom changes] I see
little merit in splitting the backend/frontend into seperate patches.
If there are any objections here, I'll step back into splitting things.

Sudarsana Reddy Kalluru (2):
  qed: add support for link pause configuration.
  qed*: Add support for read/write of eeprom

Yuval Mintz (4):
  qed*: Align statistics names
  qede: Add support for ethtool private flags
  qed*: Conditions for changing link
 
 drivers/net/ethernet/qlogic/qed/qed.h           |  10 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c        |  20 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c      |  57 +++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c       | 274 ++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h       | 103 +++++++++
 drivers/net/ethernet/qlogic/qede/qede.h         |  20 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  91 ++++++--
 drivers/net/ethernet/qlogic/qede/qede_main.c    |  29 ++-
 include/linux/qed/qed_if.h                      |  60 +++++-
 9 files changed, 610 insertions(+), 54 deletions(-)

-- 
1.9.3
