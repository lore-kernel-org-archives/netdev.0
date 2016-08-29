From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 0/3] qed*: dcbx fix series.
Date: Mon, 29 Aug 2016 08:29:51 -0400
Message-ID: <1472473794-11933-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
        <sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34338 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932900AbcH2NNn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:13:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series contains several small fixes for qed* dcbx module.

Sudarsana Reddy Kalluru (3):
  qed*: Disallow dcbx configuration for VF interfaces.
  qed: Set selection-field while configuring the app entry in ieee mode.
  qed: Clear dcbx memory buffers before the usage.
---
Please consider applying this to 'net' branch.
---

 drivers/net/ethernet/qlogic/qed/qed_dcbx.c   | 18 +++++++++++++++++-
 drivers/net/ethernet/qlogic/qede/qede_main.c |  3 ++-
 2 files changed, 19 insertions(+), 2 deletions(-)

-- 
1.8.3.1
