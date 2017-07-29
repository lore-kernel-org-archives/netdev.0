From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/2] constify net_protocol structures
Date: Sat, 29 Jul 2017 08:16:54 +0200
Message-ID: <1501309016-16059-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: bhumirks@gmail.com, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The net_protocol structure is only passed as the first argument to
inet_add_protocol or inet_del_protocol, both of which are declared
as const.  Thus the net_protocol structure itself can be const.

Done with the help of Coccinelle.

---

 net/ipv4/af_inet.c |    4 ++--
 net/l2tp/l2tp_ip.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)
