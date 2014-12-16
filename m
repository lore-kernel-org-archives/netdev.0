From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH V2 0/5] e1000e: fix nic not boot after rebooting
Date: Tue, 16 Dec 2014 18:28:15 +0800
Message-ID: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: netdev@vger.kernel.org, w@1wt.eu, zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:37880 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbaLPK2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 05:28:34 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so13843330pac.11
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 02:28:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With kernel 2.6.x, e1000e with 82577/8/9 sometimes will not boot
after rebooting. 

If a kernel 2.6.x board with 82577/8/9 e1000e nic is rebooted for 
100 times, there are 7~8 times that 82577/8/9 e1000e nic will not boot 
normally.

V2:
Follow the advice from Willy, the wrong upstream commit IDs in these
5 patches commit messages are fixed.

Zhu Yanjun (5):
  e1000e: reset MAC-PHY interconnect on 82577/82578
  e1000e: workaround EEPROM configuration change on 82579 on kernel
    2.6.x
  e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked
  e1000e: update workaround for 82579 intermittently disabled during
    S0->Sx
  e1000e: cleanup use of check_reset_block function pointer

 drivers/net/e1000e/defines.h |  2 ++
 drivers/net/e1000e/hw.h      |  1 +
 drivers/net/e1000e/ich8lan.c | 37 +++++++++++++++++++++++++++++++++++++
 3 files changed, 40 insertions(+)

-- 
1.9.1
