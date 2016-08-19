From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/2] qed*: Fix ethtool issues relating to link
Date: Fri, 19 Aug 2016 08:34:56 +0300
Message-ID: <1471584898-23253-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:19975 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753576AbcHSFfH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 01:35:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series addresses two issues that were introduced when adding
support for ethtool's link_ksettings support - the first fixes a
regression and second incorrect functionallity in the submission.

Although these are fixes, as the feature currently exists only in
'next-next' I'm aiming them for it.

Dave, please consider applying this series to 'net-next'.

Cheers,
Yuval

Yuval Mintz (2):
  qed*: Fix pause setting
  qed: Fix forcing high speeds

 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 6 +++---
 include/linux/qed/qed_if.h                      | 8 +++++---
 2 files changed, 8 insertions(+), 6 deletions(-)

-- 
1.9.3
