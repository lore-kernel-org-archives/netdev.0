From: "Benjamin Li" <benli@broadcom.com>
Subject: [PATCH 0/4] Add initial bnx2 TX multiqueue support
Date: Fri, 18 Jul 2008 14:20:46 -0700
Message-ID: <1216416050-10572-1-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2431 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751614AbYGRVVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 17:21:00 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 9C2042B0 for
 <netdev@vger.kernel.org>; Fri, 18 Jul 2008 14:20:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add initial bnx2 TX multiqueue support

These changes are to update the bnx2 driver to work with Dave's new TX
multiqueue changes.

-Ben

Benjamin Li (4):
  bnx2: Update TPAT firmware
  bnx2: Add TX multiqueue support.
  bnx2: Fix Sparse warnings
  bnx2: Update version to 1.7.9.

 drivers/net/bnx2.c     |   59 ++++---
 drivers/net/bnx2.h     |    3 +
 drivers/net/bnx2_fw2.h |  466 ++++++++++++++++++++++++------------------------
 3 files changed, 273 insertions(+), 255 deletions(-)


