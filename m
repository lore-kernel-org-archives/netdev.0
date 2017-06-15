From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: dsa: loop: Driver updates
Date: Thu, 15 Jun 2017 10:15:51 -0700
Message-ID: <20170615171553.16482-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36725 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdFORQB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 13:16:01 -0400
Received: by mail-wr0-f193.google.com with SMTP id 77so4338319wrb.3
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 10:16:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series updates drivers/net/dsa/dsa_loop.c to provide more useful
coverage of the DSA APIs and how we mangle the CPU ports ethtool statistics
to include its switch-facing port counters.

Thanks

Florian Fainelli (2):
  net: dsa: loop: Inline unregister_fixed_phys()
  net: dsa: loop: Implement ethtool statistics

 drivers/net/dsa/dsa_loop.c | 94 ++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 82 insertions(+), 12 deletions(-)

-- 
2.9.3
