From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/2] nlmon updates
Date: Thu, 19 Dec 2013 02:29:37 +0100
Message-ID: <1387416579-3098-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28637 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227Ab3LSB3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 20:29:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (2):
  netlink: only do not deliver to tap when both sides are kernel sks
  netlink: specify netlink packet direction for nlmon

 include/uapi/linux/if_packet.h |  3 +++
 net/netlink/af_netlink.c       | 15 ++++++++++-----
 2 files changed, 13 insertions(+), 5 deletions(-)

-- 
1.8.3.1
