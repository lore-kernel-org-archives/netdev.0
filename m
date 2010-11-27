From: Szymon Janc <szymon@janc.net.pl>
Subject: [PATCH 0/6] Forcedeth code style cleanup
Date: Sat, 27 Nov 2010 19:39:42 +0100
Message-ID: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Cc: Szymon Janc <szymon@janc.net.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cox.rootnode.net ([89.248.165.14]:56865 "EHLO cox.rootnode.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752130Ab0K0SvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 13:51:01 -0500
Received: from DSPAM-Daemon (localhost [127.0.0.1])
	by cox.rootnode.net (Postfix) with SMTP id 8DDA580153CC
	for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 19:41:47 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Following patches make checkpatch less unhappy about forcedeth.c.

total: 107 errors, 511 warnings, 6222 lines checked
vs
total: 12 errors, 467 warnings, 6190 lines checked

Remaining errors are false positives, remaining warnings are all lines over 80
characters.

Please keep me in CC.

Szymon Janc (6):
  forcedeth: fix multiple code style issues
  forcedeth: remove unnecessary checks before kfree
  forcedeth: include <linux/io.h> and <linux/uaccess.h> instead of    
    <asm/io.h> and <asm/uaccess.h> as suggested by checkpatch
  forcedeth: do not use assignment in if conditions
  forcedeth: use KERN_ facility level in printk
  forcedeth: use usleep_range not msleep for small sleeps

 drivers/net/forcedeth.c |  328 +++++++++++++++++++++--------------------------
 1 files changed, 148 insertions(+), 180 deletions(-)

-- 
1.7.2.3


