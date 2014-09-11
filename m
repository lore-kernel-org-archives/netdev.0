From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 0/8] ipv6: clean up locking code in anycast and mcast
Date: Thu, 11 Sep 2014 15:35:08 -0700
Message-ID: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:44887 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbaIKWfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 18:35:37 -0400
Received: by mail-pd0-f178.google.com with SMTP id p10so11260004pdj.9
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 15:35:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset cleans up the locking code in anycast.c and mcast.c
and makes the refcount code more readable.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

v1 -> v2:
* refactor some code and make it in a separated patch
* update comments

Cong Wang (8):
  ipv6: drop useless rcu_read_lock() in anycast
  ipv6: remove ipv6_sk_ac_lock
  ipv6: clean up ipv6_dev_ac_inc()
  ipv6: refactor __ipv6_dev_ac_inc()
  ipv6: drop ipv6_sk_mc_lock in mcast
  ipv6: drop some rcu_read_lock in mcast
  ipv6: update the comment in mcast.c
  ipv6: refactor ipv6_dev_mc_inc()

 include/linux/netdevice.h |   4 +-
 include/net/addrconf.h    |   2 +-
 net/core/dev.c            |  14 ++---
 net/ipv6/addrconf.c       |   2 +-
 net/ipv6/anycast.c        | 108 ++++++++++++++++++--------------------
 net/ipv6/mcast.c          | 129 +++++++++++++++++++++-------------------------
 6 files changed, 123 insertions(+), 136 deletions(-)

-- 
1.8.3.1
