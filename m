From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/2] netvsc: transparent VF related cleanups
Date: Thu, 31 Aug 2017 16:16:11 -0700
Message-ID: <20170831231613.15805-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36685 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751205AbdHaXQP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 19:16:15 -0400
Received: by mail-pf0-f177.google.com with SMTP id r187so2985508pfr.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 16:16:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first gets rid of unnecessary ref counting, and second
allows removing hv_netvsc driver even if VF present.

Stephen Hemminger (2):
  netvsc: cleanup datapath switch
  netvsc: allow driver to be removed even if VF is present

 drivers/net/hyperv/netvsc_drv.c | 55 ++++++++++++-----------------------------
 1 file changed, 16 insertions(+), 39 deletions(-)

-- 
2.11.0
