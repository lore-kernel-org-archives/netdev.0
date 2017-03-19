From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 0/9] qed: IOV related clenaups
Date: Sun, 19 Mar 2017 13:08:11 +0200
Message-ID: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45792 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751922AbdCSLIh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:08:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series targets IOV functionality [on both PF and VF].

Patches #2, #3 and #5 fix flows relating to malicious VFs, either by
upgrading and aligning current safe-guards or by correcing racy flows.

Patches #1 and #8 make some malicious/dysnfunctional VFs logging appear
by default in logs.

The rest of the patches either cleanup the existing code or else correct
some possible [yet fairly insignicant] issues in VF behavior.

Dave,

Please consider applying this series to 'net-next'.

Thanks,
Yuval

Yuval Mintz (9):
  qed: Increase verbosity of VF -> PF errors
  qed: Clean VF malicious indication when disabling IOV
  qed: Set HW-channel to ready before ACKing VF
  qed: Correct default VF coalescing configuration
  qed: Uniform IOV queue validation
  qed: Deprecate VF multiple queue-stop
  qed: Make qed_iov_mark_vf_flr() return bool
  qed: Raise verbosity of Malicious VF indications
  qed: Always publish VF link from leading hwfn

 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 286 ++++++++++++++++++----------
 drivers/net/ethernet/qlogic/qed/qed_sriov.h |  10 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.c    |  18 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.h    |   4 +
 4 files changed, 211 insertions(+), 107 deletions(-)

-- 
1.9.3
