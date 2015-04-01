From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/4] netns: enhance netlink interface for nsid
Date: Wed,  1 Apr 2015 14:49:45 +0200
Message-ID: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:55534 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442AbbDAMuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 08:50:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The first patch has been cherry-picked from the net tree to avoid any conflict
later.

The second patch is a small cleanup. The third patch implements notifications
for netns id events. And the last one allows to dump existing netns id from
userland.

iproute2 patches are available, I can send them on demand.

The diffstat does not include the first patch.

 include/uapi/linux/rtnetlink.h |   4 ++
 net/core/net_namespace.c       | 103 +++++++++++++++++++++++++++++++++++++----
 2 files changed, 97 insertions(+), 10 deletions(-)

Comments are welcome.

Regards,
Nicolas
