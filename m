From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 0/5] use setup_timer() helper function.
Date: Fri, 22 Sep 2017 16:28:17 +0530
Message-ID: <1506077902-1796-1-git-send-email-allen.lkml@gmail.com>
Cc: davem@davemloft.net, sameo@linux.intel.com,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34243 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751903AbdIVK6a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 06:58:30 -0400
Received: by mail-pg0-f68.google.com with SMTP id u18so445779pgo.1
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 03:58:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series uses setup_timer() helper function. The series
addresses the files under net/*.



Allen Pais (5):
  net: nfc: hci: use setup_timer() helper.
  net: nfc: hci: llc_shdlc: use setup_timer() helper.
  net: af_packet: use setup_timer() helper.
  net: nfc: core: use setup_timer() helper.
  net: nfc: llcp_core: use setup_timer() helper.

 net/nfc/core.c          |  5 ++---
 net/nfc/hci/core.c      |  5 ++---
 net/nfc/hci/llc_shdlc.c | 15 ++++++---------
 net/nfc/llcp_core.c     | 10 ++++------
 net/packet/af_packet.c  |  4 +---
 5 files changed, 15 insertions(+), 24 deletions(-)

-- 
2.7.4
