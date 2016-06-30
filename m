From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 0/5] qede: Enhancements
Date: Thu, 30 Jun 2016 02:35:17 -0400
Message-ID: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>, Manish <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34724 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751669AbcF3HTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 03:19:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish <manish.chopra@qlogic.com>

Hi David,

This patch series have few small fastpath features
support and code refactoring.

Note - regarding get/set tunable configuration via ethtool
Surprisingly, there is NO ethtool application support for
such configuration given that we have kernel support.
Do let us know if we need to add support for that in user ethtool.

Please consider applying this series to "net-next".

Thanks,
Manish

Manish Chopra (5):
  qede: Add support for handling IP fragmented packets.
  qede: qede_poll refactoring
  qede: Utilize xmit_more
  qede: Add get/set rx copy break tunable support
  qede: Bump up driver version to 8.10.1.20

 drivers/net/ethernet/qlogic/qede/qede.h         |   6 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  47 ++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 138 ++++++++++++++----------
 3 files changed, 133 insertions(+), 58 deletions(-)

-- 
2.7.2
