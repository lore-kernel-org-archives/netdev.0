From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 0/2] qed*: Fixes to "Allow unicast filtering"
Date: Mon, 31 Oct 2016 22:26:52 +0200
Message-ID: <1477945614-29133-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:41210 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S946472AbcJaU1J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:27:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7b7e70f979e3 ("qed*: Allow unicast filtering") introduced several
issues in driver. This series is intended to address and fix those.

Dave,

These are fixes but I believe the original commit hasn't reached net yet.
So please consider applying these to `net-next'.

Thanks,
Yuval

Yuval Mintz (2):
  qede: Don't override priv_flags
  qed: Correct VF mac number

 drivers/net/ethernet/qlogic/qed/qed_l2.c     |  2 ++
 drivers/net/ethernet/qlogic/qed/qed_vf.c     |  7 +++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h     | 13 +++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c |  2 +-
 4 files changed, 23 insertions(+), 1 deletion(-)

-- 
1.9.3
