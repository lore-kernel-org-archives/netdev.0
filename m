From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 0/5] ipv6: clean up locking in anycast and mcast
Date: Tue,  9 Sep 2014 16:52:13 -0700
Message-ID: <1410306738-18036-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:54968 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbaIIXwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 19:52:35 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so9046748pad.35
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 16:52:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset cleans up the locking in anycast.c and mcast.c.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Cong Wang (5):
  ipv6: drop useless rcu_read_lock() in anycast
  ipv6: remove ipv6_sk_ac_lock
  ipv6: clean up ipv6_dev_ac_inc()
  ipv6: drop ipv6_sk_mc_lock in mcast
  ipv6: drop some rcu_read_lock in mcast

 include/linux/netdevice.h |  4 ++--
 include/net/addrconf.h    |  2 +-
 net/core/dev.c            | 14 +++++++------
 net/ipv6/addrconf.c       |  2 +-
 net/ipv6/anycast.c        | 52 +++++++++++++----------------------------------
 net/ipv6/mcast.c          | 35 ++++++-------------------------
 6 files changed, 32 insertions(+), 77 deletions(-)

-- 
1.8.3.1
