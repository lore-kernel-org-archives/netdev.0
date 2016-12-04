From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 0/2] bnx2x: fixes series
Date: Sun, 4 Dec 2016 15:30:16 +0200
Message-ID: <1480858218-13187-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34100 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751372AbcLDNab (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 08:30:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Two unrelated fixes for bnx2x - the first one is nice-to-have,
while the other fixes fatal behaviour in older adapters.

Please consider applying them to `net'.

Thanks,
Yuval

Yuval Mintz (2):
  bnx2x: Correct ringparam estimate when interface is down
  bnx2x: Prevent tunnel configuration for 577xx adapters.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 8 ++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    | 4 ++--
 2 files changed, 10 insertions(+), 2 deletions(-)

-- 
1.9.3
