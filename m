From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 0/2] net: some minor optimization for netns id
Date: Thu,  1 Sep 2016 21:53:43 -0700
Message-ID: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33580 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbcIBEyy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 00:54:54 -0400
Received: by mail-pa0-f65.google.com with SMTP id vy10so5065199pac.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 21:53:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Cong Wang (2):
  vxlan: call peernet2id() in fdb notification
  netns: avoid disabling irq for netns id

 drivers/net/vxlan.c      |  2 +-
 net/core/net_namespace.c | 37 ++++++++++++++++---------------------
 2 files changed, 17 insertions(+), 22 deletions(-)

-- 
2.1.0
