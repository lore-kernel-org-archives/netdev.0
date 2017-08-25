From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 0/2] drivers: net: xgene: Misc bug fixes
Date: Fri, 25 Aug 2017 15:23:28 -0700
Message-ID: <1503699810-12803-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, dnelson@redhat.com,
        qnguyen@apm.com, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:37737 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933777AbdHYWXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 18:23:46 -0400
Received: by mail-pg0-f54.google.com with SMTP id 83so5657838pgb.4
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 15:23:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set,

     1. Adds call to PHY disconnect in the case of error
     2. Cleans up all outstanding TX descriptors when the driver is
	being rmmod'd

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

Iyappan Subramanian (1):
  drivers: net: xgene: Clean up all outstanding tx descriptors

Quan Nguyen (1):
  drivers: net: xgene: Correct probe sequence handling

 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 147 ++++++++++++++++-------
 1 file changed, 102 insertions(+), 45 deletions(-)

-- 
2.7.4
