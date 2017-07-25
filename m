From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 0/1] fix bug in netvsc driver
Date: Mon, 24 Jul 2017 21:03:18 -0700
Message-ID: <20170725040319.5969-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35465 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751196AbdGYEGg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 00:06:36 -0400
Received: by mail-pf0-f182.google.com with SMTP id h29so19229314pfd.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 21:06:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Internal testing found a problem under some load tests and the problem
was bisected down to one commit.
This needs to go to current (4.13) and stable (4.12).

Stephen Hemminger (1):
  Revert "netvsc: optimize calculation of number of slots"

 drivers/net/hyperv/netvsc_drv.c | 43 +++++++++++++++++++++++++++++++----------
 1 file changed, 33 insertions(+), 10 deletions(-)

-- 
2.11.0
