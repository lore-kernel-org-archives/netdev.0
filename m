From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 0/4] Geneve Cleanups
Date: Fri,  2 Jan 2015 18:26:01 -0800
Message-ID: <1420251965-44794-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:42478 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752039AbbACC0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 21:26:11 -0500
Received: by mail-qa0-f50.google.com with SMTP id dc16so12977107qab.23
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 18:26:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Much of the basis for the Geneve code comes from VXLAN. However,
Geneve is quite a bit simpler than VXLAN and so this cleans up a
lot of the infrastruction - particularly around locking - where the
extra complexity is not necessary.

Jesse Gross (4):
  geneve: Remove workqueue.
  geneve: Simplify locking.
  geneve: Remove socket hash table.
  geneve: Check family when reusing sockets.

 include/net/geneve.h |   5 +--
 net/ipv4/geneve.c    | 101 +++++++++++++++++----------------------------------
 2 files changed, 35 insertions(+), 71 deletions(-)

-- 
1.9.1
