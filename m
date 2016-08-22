From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH ethtool 0/3] ethtool: Add support for new high speed adv.
Date: Mon, 22 Aug 2016 08:50:36 +0300
Message-ID: <1471845039-28718-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vidya@cumulusnetworks.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>, <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39411 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751736AbcHVFvQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 01:51:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows ethtool to utilize the link capabilities/adv./lp bitmasks
to show and set the additional 25g, 50g and 100g link speeds.

Patches #1 & #2 are based on Vidya Sagar Ravipati's patches
[with the only addition being the addition of the 50g SR2 mode],
while patch #3 updates the man-page with the additional modes.

Can't claim to have tried all modes, although I did play with both
25g KR and 50g KR2 which seemed to be working fine.

Yuval Mintz (3):
  ethtool: Copy high-speed bits from ethtool.h
  ethtool: Add support 25g, 50g and 100g speeds
  ethtool: Document new ethtool advertise speeds

 ethtool-copy.h | 12 +++++++++++-
 ethtool.8.in   | 10 ++++++++++
 ethtool.c      | 30 ++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+), 1 deletion(-)

-- 
1.9.3
