From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 0/2] bonding: create same number of queues on all creations
Date: Wed, 10 Aug 2011 18:09:43 +0200
Message-ID: <1312992585-1201-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63205 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582Ab1HJQKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 12:10:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bonding device is created via /sys/class/net/bonding_masters,
correct number of queues is created. But if bonding device is created via rtnl,
default single queue is created. This little patchset makes it behaves the same.

Jiri Pirko (2):
  bonding: implement get_tx_queues rtnk_link_op
  rtnetlink: remove initialization of dev->real_num_tx_queues

 drivers/net/bonding/bond_main.c |    9 +++++++++
 net/core/rtnetlink.c            |    1 -
 2 files changed, 9 insertions(+), 1 deletions(-)

-- 
1.7.6

