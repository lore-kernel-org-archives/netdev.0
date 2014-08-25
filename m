From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/5] bnx2x: `fixes' patch-series
Date: Mon, 25 Aug 2014 17:48:28 +0300
Message-ID: <1408978113-27902-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:4833 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932509AbaHYOsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:48:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series contains mostly bug fixes, but never the less is intended
for `net-next' and not `net', as:
  - Some of the fixes are quite insignificant [`VF clean statistics',
    `ethtool -d might cause timeout in log'].
  - Some only recently were submitted to `net-next' [`Fix timesync endianity'].
  - Some are not usually compiled as part of the kernel [`Fix stop-on-error'].

Dave - please consider applying this series to `net-next'; If you prefer,
I can break this series into 2 parts [one for `net' and the other for
`net-next'] - but personally I don't see much benefit in it.

Thanks,
Yuval Mintz

Dmitry Kravkov (2):
  bnx2x: ethtool -d might cause timeout in log
  bnx2x: Be more forgiving toward SW GRO

Michal Kalderon (1):
  bnx2x: Fix timesync endianity

Yuval Mintz (2):
  bnx2x: Fix stop-on-error
  bnx2x: VF clean statistics

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   | 35 +++++++++++++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h  | 14 ++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c    |  6 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |  5 ++++
 5 files changed, 44 insertions(+), 18 deletions(-)

-- 
1.8.3.1
