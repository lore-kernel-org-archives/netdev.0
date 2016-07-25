From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/3] bnxt_en: Improve ntuple filters and add new IDs.
Date: Sun, 24 Jul 2016 23:21:54 -0400
Message-ID: <1469416917-29659-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35134 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbcGYDWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2016 23:22:07 -0400
Received: by mail-pa0-f41.google.com with SMTP id iw10so56481412pac.2
        for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 20:22:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve ntuple filters and add some new PCI device IDs.  Please review
for net-next.

Michael Chan (2):
  bnxt_en: Improve ntuple filters by checking destination MAC address.
  bnxt_en: Add new NPAR and dual media device IDs.

Vasundhara Volam (1):
  bnxt_en: Log a message, if enabling NTUPLE filtering fails.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 74 ++++++++++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  2 +
 2 files changed, 65 insertions(+), 11 deletions(-)

-- 
1.8.3.1
