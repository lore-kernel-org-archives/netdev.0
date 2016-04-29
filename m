From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 0/3] qed/qede: ethtool selftests support.
Date: Thu, 28 Apr 2016 20:20:51 -0400
Message-ID: <1461889254-10534-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>, <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60846 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752792AbcD2BDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 21:03:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This series adds the driver support for following selftests:
1. Register test
2. Memory test
3. Clock test
4. Interrupt test
5. Internal loopback test
Patch (1) adds the qed driver infrastructure for selftests. Patches (2) and
(3) add qede driver support for ethtool selftests.

Please consider applying this series to "net-next".

Thanks,
Sudarsana

Sudarsana Reddy Kalluru (3):
  qed: add infrastructure for device self tests.
  qede: add support for selftests.
  qede: add implementation for internal loopback test.

 drivers/net/ethernet/qlogic/qed/Makefile          |   3 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         |  13 +
 drivers/net/ethernet/qlogic/qed/qed_main.c        |  28 +++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         |  42 ++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h         |  22 ++
 drivers/net/ethernet/qlogic/qed/qed_selftest.c    |  76 ++++++
 drivers/net/ethernet/qlogic/qed/qed_selftest.h    |  40 +++
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |  10 +
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |  21 ++
 drivers/net/ethernet/qlogic/qede/qede.h           |   4 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c   | 290 +++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qede/qede_main.c      |   8 +-
 include/linux/qed/qed_if.h                        |  47 ++++
 13 files changed, 598 insertions(+), 6 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_selftest.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_selftest.h

-- 
1.8.3.1
