From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 3/3] xen/9pfs: don't inclide rwlock.h directly.
Date: Thu,  5 Oct 2017 14:56:55 +0200
Message-ID: <20171005125655.12373-3-bigeasy@linutronix.de>
References: <20171005125655.12373-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Cc: tglx@linutronix.de,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "David S. Miller" <davem@davemloft.net>,
        v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005125655.12373-1-bigeasy@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rwlock.h should not be included directly. Instead linux/splinlock.h
should be included. One thing it does is to break the RT build.

Cc: Eric Van Hensbergen <ericvh@gmail.com>
Cc: Ron Minnich <rminnich@sandia.gov>
Cc: Latchesar Ionkov <lucho@ionkov.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: v9fs-developer@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 net/9p/trans_xen.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/9p/trans_xen.c b/net/9p/trans_xen.c
index 6ad3e043c617..02c6c467a99c 100644
--- a/net/9p/trans_xen.c
+++ b/net/9p/trans_xen.c
@@ -38,7 +38,6 @@
=20
 #include <linux/module.h>
 #include <linux/spinlock.h>
-#include <linux/rwlock.h>
 #include <net/9p/9p.h>
 #include <net/9p/client.h>
 #include <net/9p/transport.h>
--=20
2.14.2
