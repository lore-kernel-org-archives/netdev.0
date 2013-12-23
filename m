From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 0/2] nlmon updates
Date: Mon, 23 Dec 2013 09:48:37 +0100
Message-ID: <1387788519-17722-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51513 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757049Ab3LWIsm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Dec 2013 03:48:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (2):
  netlink: only do not deliver to tap when both sides are kernel sks
  netlink: specify netlink packet direction for nlmon

 include/uapi/linux/if_packet.h |  4 +++-
 net/netlink/af_netlink.c       | 15 ++++++++++-----
 2 files changed, 13 insertions(+), 6 deletions(-)

-- 
1.7.11.7
