From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/3] net: systemport: TX/NAPI improvements
Date: Thu, 23 Mar 2017 10:36:45 -0700
Message-ID: <20170323173648.21143-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36688 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752529AbdCWRh5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 13:37:57 -0400
Received: by mail-wm0-f66.google.com with SMTP id x124so555485wmf.3
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 10:37:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series builds up on Doug's latest changes done in BCMGENET to reduce
the number of spurious interrupts in NAPI, simplify pointer arithmetic and
finally tracking of per TX ring statistics to be SMP friendly.

Florian Fainelli (3):
  net: systemport: Track per TX ring statistics
  net: systemport: Clear status to reduce spurious interrupts
  net: systemport: Simplify circular pointer arithmetic

 drivers/net/ethernet/broadcom/bcmsysport.c | 81 +++++++++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bcmsysport.h |  5 ++
 2 files changed, 74 insertions(+), 12 deletions(-)

-- 
2.9.3
