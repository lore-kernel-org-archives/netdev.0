From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/4] qed: Attention support patch series
Date: Sun, 28 Feb 2016 12:26:51 +0200
Message-ID: <1456655215-16345-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:65473 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757210AbcB1K1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 05:27:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now we've only enabled attention generation for the sake of
management firmware indications [required for link notifications].

This series enables [almost] all the attention sources of the HW,
currently for the sake of logging information relating to issues
experienced by HW. In future, infrastructure laid here would also be used
for the sake of the recovery process.

The first patch in the series is a semantic alignemnt of the code.
The later 3 patches incremently create said infrastructure and enrich
the logged information.
Notice #3 contains quite a bit of structures [consisting of ~1K lines]
that will eventually be removed and incorporated in the binary fw file.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Yuval Mintz (4):
  qed: Semantic refactoring of interrupt code
  qed: Add support for HW attentions
  qed: Print HW attention reasons
  qed: Print additional HW attention info

 drivers/net/ethernet/qlogic/qed/qed_dev.c      |    6 +-
 drivers/net/ethernet/qlogic/qed/qed_int.c      | 2195 ++++++++++++++++++++++--
 drivers/net/ethernet/qlogic/qed/qed_int.h      |    6 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c     |   15 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   60 +
 include/linux/qed/qed_if.h                     |    6 +
 6 files changed, 2171 insertions(+), 117 deletions(-)

-- 
1.9.3
