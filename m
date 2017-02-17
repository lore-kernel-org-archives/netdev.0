From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/3] sfc: misc. fixes
Date: Fri, 17 Feb 2017 15:47:32 +0000
Message-ID: <f49743cd-3227-4d30-9d6d-bd2f8400df62@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:65377 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934564AbdBQPrq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 10:47:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three largely unrelated fixes to increase robustness in rare edge cases.

Bert Kenward (1):
  sfc: forget filters from sw table if hw replies ENOENT on removing
    them

Jon Cooper (1):
  sfc: fix filter_id misinterpretation in edge case

Peter Dunning (1):
  sfc: do not device_attach if a reset is pending

 drivers/net/ethernet/sfc/ef10.c       | 67 ++++++++++++++++++++++-------------
 drivers/net/ethernet/sfc/ef10_sriov.c |  4 +--
 drivers/net/ethernet/sfc/efx.c        | 10 +++---
 drivers/net/ethernet/sfc/efx.h        |  6 ++++
 drivers/net/ethernet/sfc/selftest.c   |  2 +-
 5 files changed, 57 insertions(+), 32 deletions(-)
