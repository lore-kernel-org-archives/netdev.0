From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 0/4] qed: dcbx fix series.
Date: Mon, 8 Aug 2016 21:57:39 -0400
Message-ID: <1470707863-11712-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:62214 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752308AbcHIClE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 22:41:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch series contains the minor bug fixes for qed dcbx module.
Please consider applying this to 'net' branch.

Sudarsana Reddy Kalluru (4):
  qed: Remove the endian-ness conversion for pri_to_tc value.
  qed: Use ieee mfw-mask to get ethtype in ieee-dcbx mode.
  qed: Add dcbx app support for IEEE Selection Field.
  qed: Update app count when adding a new dcbx app entry to the table.

 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 223 ++++++++++++++++++++++-------
 drivers/net/ethernet/qlogic/qed/qed_hsi.h  |   8 ++
 include/linux/qed/qed_if.h                 |   8 ++
 3 files changed, 185 insertions(+), 54 deletions(-)

-- 
1.8.3.1
