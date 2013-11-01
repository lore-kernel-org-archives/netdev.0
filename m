From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCHv2 net-next 0/7] smsc: replace printk with netdev_ calls
Date: Fri,  1 Nov 2013 00:27:16 -0400
Message-ID: <1383280043-13552-1-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:49928 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab3KAE13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 00:27:29 -0400
Received: by mail-qa0-f45.google.com with SMTP id ii20so381889qab.18
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 21:27:28 -0700 (PDT)
In-Reply-To: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up printk calls in smsc network drivers by using netdev_<level>
instead.

I've compile tested them all on x86 by forcing them to at least compile to
catch obvious errors.

Ben Boeckel (7):
  epic100: replace printk with netdev_ calls
  smc91x: replace printk with netdev_ calls
  smc911x: replace printk with netdev_ calls
  smsc911x: replace printk with netdev_ calls
  smc9194: replace printk with netdev_ calls
  smc91c92_cs: replace printk with netdev_ calls
  smsc9420: replace printk with netdev_ calls

 drivers/net/ethernet/smsc/epic100.c     | 121 ++++++------
 drivers/net/ethernet/smsc/smc911x.c     | 331 ++++++++++++++++----------------
 drivers/net/ethernet/smsc/smc911x.h     |   2 +-
 drivers/net/ethernet/smsc/smc9194.c     |  52 +++--
 drivers/net/ethernet/smsc/smc91c92_cs.c |  43 ++---
 drivers/net/ethernet/smsc/smc91x.c      | 237 +++++++++++------------
 drivers/net/ethernet/smsc/smc91x.h      |   4 +-
 drivers/net/ethernet/smsc/smsc911x.c    |   2 +-
 drivers/net/ethernet/smsc/smsc9420.c    |  26 +--
 9 files changed, 400 insertions(+), 418 deletions(-)

-- 
1.8.4.2
