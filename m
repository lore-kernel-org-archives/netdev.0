From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net 0/3] qede: Bug fixes
Date: Wed, 20 Apr 2016 03:03:26 -0400
Message-ID: <1461135809-9776-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:40658 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753990AbcDTHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 03:45:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This series fixes -

* various memory allocation failure flows for fastpath
* issues with respect to driver GRO packets handling

V1->V2

* Send series against net instead of net-next.

Please consider applying this series to "net"

Thanks,
Manish

Manish Chopra (3):
  qede: Fix various memory allocation error flows for fastpath
  qede: Fix setting Skb network header
  qede: Fix single MTU sized packet from firmware GRO flow

 drivers/net/ethernet/qlogic/qede/qede_main.c | 157 +++++++++++++++++----------
 1 file changed, 100 insertions(+), 57 deletions(-)

-- 
2.7.2
