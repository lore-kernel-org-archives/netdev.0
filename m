From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 0/3] drivers: net: xgene: Misc bug fixes
Date: Tue,  5 Sep 2017 11:16:29 -0700
Message-ID: <1504635392-19089-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, dnelson@redhat.com,
        patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:38643 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752404AbdIESQs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 14:16:48 -0400
Received: by mail-pg0-f54.google.com with SMTP id v66so10735428pgb.5
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 11:16:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes bugs related to handling the case for ACPI for,
reading and programming tx/rx delay values.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

Iyappan Subramanian (2):
  drivers: net: xgene: Read tx/rx delay for ACPI
  drivers: net: xgene: Remove return statement from void function

Quan Nguyen (1):
  drivers: net: xgene: Configure tx/rx delay for ACPI

 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   | 7 ++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 6 ++----
 2 files changed, 4 insertions(+), 9 deletions(-)

-- 
2.7.4
