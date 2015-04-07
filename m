From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 0/3] netns: enhance netlink interface for nsid
Date: Tue,  7 Apr 2015 11:51:51 +0200
Message-ID: <1428400314-4472-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:59894 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104AbbDGJv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 05:51:56 -0400
In-Reply-To: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The first patch is a small cleanup. The second patch implements notifications
for netns id events. And the last one allows to dump existing netns id from
userland.

iproute2 patches are available, I can send them on demand.

v2: drop the first patch (the fix is now in net-next)

 include/uapi/linux/rtnetlink.h |   4 ++
 net/core/net_namespace.c       | 103 +++++++++++++++++++++++++++++++++++++----
 2 files changed, 97 insertions(+), 10 deletions(-)

Comments are welcome.

Regards,
Nicolas
