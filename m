From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/1] netvsc: another VF datapath fix
Date: Mon,  7 Aug 2017 11:29:59 -0700
Message-ID: <20170807183000.10827-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:37138 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751589AbdHGSaG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:30:06 -0400
Received: by mail-pg0-f51.google.com with SMTP id y129so4694198pgy.4
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:30:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previous fix was incomplete.

Stephen Hemminger (1):
  netvsc: make sure and unregister datapath

 drivers/net/hyperv/hyperv_net.h |  3 --
 drivers/net/hyperv/netvsc.c     |  2 --
 drivers/net/hyperv/netvsc_drv.c | 71 ++++++++++++++++-------------------------
 3 files changed, 28 insertions(+), 48 deletions(-)

-- 
2.11.0
