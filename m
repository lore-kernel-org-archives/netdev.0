From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 0/4] l2tp: remove unused code
Date: Tue, 31 Oct 2017 17:36:41 +0100
Message-ID: <cover.1509466904.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38621 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753319AbdJaQgo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 12:36:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch #1 removes the ref/deref mechanism that was originally used to
prevent ppp pseudowires from dropping their sockets. This mechanism
was error prone and isn't used anymore.

Patch #2 removes some module specific refcount debugging.
Patches #3 and #4 take care of some dead code.

Guillaume Nault (4):
  l2tp: remove ->ref() and ->deref()
  l2tp: remove l2tp specific refcount debugging
  l2tp: remove l2tp_tunnel_count and l2tp_session_count
  l2tp: remove field 'dev' from struct l2tp_eth

 net/l2tp/l2tp_core.c    | 62 +++++++------------------------------------------
 net/l2tp/l2tp_core.h    | 34 ++++-----------------------
 net/l2tp/l2tp_debugfs.c |  4 +---
 net/l2tp/l2tp_eth.c     |  5 ----
 net/l2tp/l2tp_ip.c      |  4 +---
 net/l2tp/l2tp_ip6.c     |  4 +---
 net/l2tp/l2tp_netlink.c | 20 +++++++---------
 net/l2tp/l2tp_ppp.c     | 10 +++-----
 8 files changed, 27 insertions(+), 116 deletions(-)

-- 
2.15.0
