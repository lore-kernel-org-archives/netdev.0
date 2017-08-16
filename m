From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/3] vmbus sendpacket cleanups
Date: Wed, 16 Aug 2017 08:56:23 -0700
Message-ID: <20170816155626.16580-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34069 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbdHPP4e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 11:56:34 -0400
Received: by mail-pg0-f44.google.com with SMTP id u185so24673867pgb.1
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 08:56:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches remove and consolidate vmbus_sendpacket functions.

They should go through the net-next tree since these API's
were only used by the netvsc driver.

Stephen Hemminger (3):
  vmbus: remove unused vmbus_sendpacket_multipagebuffer
  vmbus: remove unused vmubs_sendpacket_pagebuffer_ctl
  vmbus: remove unused vmbus_sendpacket_ctl

 drivers/hv/channel.c        | 129 ++++++++------------------------------------
 drivers/net/hyperv/netvsc.c |  19 +++----
 include/linux/hyperv.h      |  21 --------
 3 files changed, 31 insertions(+), 138 deletions(-)

-- 
2.11.0
