From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 0/2] netlink: implement socket diag for netlink sockets
Date: Thu, 21 Mar 2013 13:21:07 +0400
Message-ID: <1363857669-19990-1-git-send-email-avagin@openvz.org>
Cc: Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Andrey Vagin <avagin@openvz.org>

Andrey Vagin (2):
  net: prepare netlink code for netlink diag
  netlink: Diag core and basic socket info dumping

 include/uapi/linux/netlink_diag.h |  40 ++++++++
 net/Kconfig                       |   1 +
 net/netlink/Kconfig               |  10 ++
 net/netlink/Makefile              |   3 +
 net/netlink/af_netlink.c          |  59 +-----------
 net/netlink/af_netlink.h          |  62 +++++++++++++
 net/netlink/diag.c                | 186 ++++++++++++++++++++++++++++++++++++++
 7 files changed, 307 insertions(+), 54 deletions(-)
 create mode 100644 include/uapi/linux/netlink_diag.h
 create mode 100644 net/netlink/Kconfig
 create mode 100644 net/netlink/af_netlink.h
 create mode 100644 net/netlink/diag.c

-- 
1.8.1.4
