From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] r8169: Be drop monitor friendly
Date: Thu, 24 Aug 2017 18:33:57 -0700
Message-ID: <20170825013359.27258-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, nic_swsd@realtek.com, romieu@fr.zoreil.com,
        edumazet@gmail.com, alexander.h.duyck@intel.com,
        sgruszka@redhat.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36668 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754349AbdHYBeI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 21:34:08 -0400
Received: by mail-qk0-f196.google.com with SMTP id p67so1059872qkd.3
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 18:34:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

First patch may be questionable but no other driver appears to be doing that
and while it is defendable to account for left packets as dropped during TX
clean, this appears misleadning. I picked Stanislaw changes which brings us
back to 2010, but this was present from pre-git days as well.

Second patch fixes the two missing calls to dev_consume_skb_any().

Florian Fainelli (2):
  r8169: Do not increment tx_dropped in TX ring cleaning
  r8169: Be drop monitor friendly

 drivers/net/ethernet/realtek/r8169.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

-- 
2.9.3
