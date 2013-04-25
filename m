From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v4 0/3] packet_diag: enhance advertised infos
Date: Thu, 25 Apr 2013 18:53:51 +0200
Message-ID: <1366908834-21606-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1366903930.8964.154.camel@edumazet-glaptop>
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56525 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759011Ab3DYQx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 12:53:57 -0400
In-Reply-To: <1366903930.8964.154.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patchset is to be able to get all infos exported via the
/proc/net/packet and also beeing able to get filter associated to af_packet
sockets.

As usual, the patch against iproute2 will be sent once the patches are included
and net-next merged. I can send it on demand.

v2: add sock_diag_notify_del() to avoid confusion of the meaning of the second
    arg of __sock_diag_notify()
    enhance commitlog of patch 3/5

v3: drop previous 4/5 and 5/5 patches
    add patch 3/4 (sock_diag: do not disclose sock ptr to all users)
    disclose filters only to allowed users

v4: drop patch 3/4 (sock_diag: do not disclose sock ptr to all user)

 include/linux/sock_diag.h        |  3 +++
 include/uapi/linux/packet_diag.h |  5 +++++
 net/core/sock_diag.c             | 33 +++++++++++++++++++++++++++++++++
 net/packet/diag.c                | 27 ++++++++++++++++++++++-----
 4 files changed, 63 insertions(+), 5 deletions(-)

Comments are welcome.

Regards,
Nicolas
