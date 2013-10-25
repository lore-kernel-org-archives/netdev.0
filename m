From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCH net-next 0/6] smsc: replace printk with netdev_ calls
Date: Fri, 25 Oct 2013 02:26:56 -0400
Message-ID: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f53.google.com ([209.85.128.53]:33240 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3JYG1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 02:27:10 -0400
Received: by mail-qe0-f53.google.com with SMTP id cy11so2090445qeb.12
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 23:27:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up printk calls in smsc network drivers by using netdev_<level>
instead.

Ben Boeckel (6):
  epic100: replace printk with netdev_ calls
  smc91x: replace printk with netdev_ calls
  smc911x: replace printk with netdev_ calls
  smc9194: replace printk with netdev_ calls
  smc91c92_cs: replace printk with netdev_ calls
  smsc9420: replace printk with netdev_ calls

 drivers/net/ethernet/smsc/epic100.c     | 57 ++++++++++++++++-----------------
 drivers/net/ethernet/smsc/smc911x.c     | 34 +++++++++++---------
 drivers/net/ethernet/smsc/smc911x.h     |  2 +-
 drivers/net/ethernet/smsc/smc9194.c     | 24 +++++++-------
 drivers/net/ethernet/smsc/smc91c92_cs.c |  5 ++-
 drivers/net/ethernet/smsc/smc91x.c      | 53 +++++++++++++++---------------
 drivers/net/ethernet/smsc/smc91x.h      |  2 +-
 drivers/net/ethernet/smsc/smsc9420.c    |  8 ++---
 8 files changed, 92 insertions(+), 93 deletions(-)

-- 
1.8.3.1
