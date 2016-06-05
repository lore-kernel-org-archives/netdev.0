From: zyjzyj2000@gmail.com
Subject: ixgbe: replace rtnl_lock with rcu_read_lock
Date: Sun,  5 Jun 2016 17:14:50 +0800
Message-ID: <1465118091-6233-1-git-send-email-zyjzyj2000@gmail.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [111.193.70.236] ([111.193.70.236]:56848 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750785AbcFEJUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jun 2016 05:20:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,all

 I am using the ixgbe nic. I found that the rtnl_lock is being 
 used to enable upper device, such as macvlan. I am curious
 why rcu_read_lock is not used here.

 I replaced rtnl_lock with rcu_read_lock here. Then I made tests and
 it can work well.

 So can the rtnl_lock be replaced with rcu_read_lock?
 Anyone can explain it in details?

 Any reply is appreciated.
 Zhu Yanjun
