From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 0/3] bnxt_en: Improve ntuple filters and add new IDs.
Date: Mon, 25 Jul 2016 12:33:34 -0400
Message-ID: <1469464417-786-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34935 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbcGYQdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 12:33:53 -0400
Received: by mail-pa0-f50.google.com with SMTP id iw10so62712920pac.2
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 09:33:53 -0700 (PDT)
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
