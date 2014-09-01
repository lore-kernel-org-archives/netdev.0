From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/4] rtnl: send notification in do_setlink()
Date: Mon,  1 Sep 2014 16:07:25 +0200
Message-ID: <1409580449-4562-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:36488 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754147AbaIAOQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 10:16:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This serie ensures to call the notifier chain and to send a netlink message when
a change is done by do_setlink().

The three first patches mainly prepare the last one, which do this change.

 net/core/rtnetlink.c | 66 +++++++++++++++++++++++++++++++++-------------------
 1 file changed, 42 insertions(+), 24 deletions(-)

Comments are welcome.

Regards,
Nicolas
