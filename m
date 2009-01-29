From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 0/1] smsc9420: fix interrupt signalling test failures
Date: Thu, 29 Jan 2009 16:39:22 +0000
Message-ID: <1233247163-4317-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:45938 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751942AbZA2QjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 11:39:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

One important driver fix for you, please apply to 2.6.29 as the driver 
will fail to initialise on some platforms without it.

I'm amazed this test ever passed, I guess it's because I'm on a fast
SMP machine which managed to beat the race.

Steve Glendinning (1):
  smsc9420: fix interrupt signalling test failures

 drivers/net/smsc9420.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

