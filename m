From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/3] [IUCV] fixes for net-2.6.25
Date: Thu, 07 Feb 2008 15:28:42 +0100
Message-ID: <20080207142842.852003000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:21920 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755830AbYBGOfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 09:35:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Dave,

the following 3 patches are intended for 2.6.25 and contain:
- locking changes in iucv.c
- locking changes in af_iucv.c
- extra checkings for successful allocations in af_iucv.c
- secure handling of send_skb_q list in af_iucv.c
