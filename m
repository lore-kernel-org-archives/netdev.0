From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net 0/4] qed: Bug fixes
Date: Mon, 7 Dec 2015 06:25:55 -0500
Message-ID: <1449487559-31811-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:20296 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754774AbbLGMGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 07:06:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Please consider applying this series to net.

Thanks,
Manish

V2:
- Use available helpers for declaring bitmap
  and bitmap operations.

Ariel Elior (1):
  qed: Fix BAR size split for some servers

Sudarsana Kalluru (1):
  qed: Correct slowpath interrupt scheme

Tomer Tayar (2):
  qed: Fix corner case for chain in-between pages
  qed: fix handling of concurrent ramrods.

 drivers/net/ethernet/qlogic/qed/qed.h          |    3 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |   53 ++++++++++++--------
 drivers/net/ethernet/qlogic/qed/qed_int.c      |   33 +++++++++---
 drivers/net/ethernet/qlogic/qed/qed_int.h      |   15 ++++--
 drivers/net/ethernet/qlogic/qed/qed_main.c     |   56 +++++++--------------
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |    4 ++
 drivers/net/ethernet/qlogic/qed/qed_sp.h       |    8 ++-
 drivers/net/ethernet/qlogic/qed/qed_spq.c      |   63 ++++++++++++++++++------
 include/linux/qed/common_hsi.h                 |    2 +
 include/linux/qed/qed_chain.h                  |    3 +-
 10 files changed, 149 insertions(+), 91 deletions(-)
