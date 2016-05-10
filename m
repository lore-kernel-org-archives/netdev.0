From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/2] bnxt_en: Add workaround to detect bad opaque in rx completion.
Date: Tue, 10 May 2016 19:17:58 -0400
Message-ID: <1462922280-17851-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34439 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbcEJXSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 19:18:10 -0400
Received: by mail-pf0-f170.google.com with SMTP id y69so10797060pfb.1
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 16:18:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2-part workaround for this hardware bug.

Michael Chan (2):
  bnxt_en: Add workaround to detect bad opaque in rx completion (part 1)
  bnxt_en: Add workaround to detect bad opaque in rx completion (part 2)

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 63 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  2 +
 2 files changed, 65 insertions(+)

-- 
1.8.3.1
