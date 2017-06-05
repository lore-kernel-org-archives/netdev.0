From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 0/3] netvsc bug fixes
Date: Mon,  5 Jun 2017 14:10:07 -0700
Message-ID: <20170605211010.9571-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33930 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdFEVKU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 17:10:20 -0400
Received: by mail-pf0-f169.google.com with SMTP id 9so88310425pfj.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 14:10:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are non-critical bug fixes to the 4.12 version of netvsc
network driver. Two fix RCU splat warnings, and the other fixes
long standing issue with net poll. I don't think anyone has run
into the net poll issue before, so not worth incorporating into
stable.

Stephen Hemminger (3):
  netvsc: fix rcu dereference warning from ethtool
  netvsc: fix net poll mode
  netvsc: fix RCU warning from set_multicast

 drivers/net/hyperv/netvsc_drv.c | 55 +++++++++++++++++++++++++----------------
 1 file changed, 34 insertions(+), 21 deletions(-)

-- 
2.11.0
