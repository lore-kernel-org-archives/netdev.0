From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH] bpf: cgroup: fix documentation of __cgroup_bpf_update()
Date: Mon, 28 Nov 2016 12:04:59 +0100
Message-ID: <1480331099-20216-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, roszenrami@gmail.com,
        cgroups@vger.kernel.org, Daniel Mack <daniel@zonque.org>
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:34285 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932094AbcK1LFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 06:05:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a 'not' missing in one paragraph. Add it.

Signed-off-by: Daniel Mack <daniel@zonque.org>
Reported-by: Rami Rosen <roszenrami@gmail.com>
Fixes: 3007098494be ("cgroup: add support for eBPF programs")
---
 kernel/bpf/cgroup.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index a0ab43f..b708e6e 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -70,9 +70,9 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
  * releases the one that is currently attached, if any. @prog is then made
  * the effective program of type @type in that cgroup.
  *
- * If @prog is %NULL, the currently attached program of type @type is released,
- * and the effective program of the parent cgroup (if any) is inherited to
- * @cgrp.
+ * If @prog is not %NULL, the currently attached program of type @type is
+ * released, and the effective program of the parent cgroup (if any) is
+ * inherited to @cgrp.
  *
  * Then, the descendants of @cgrp are walked and the effective program for
  * each of them is set to the effective program of @cgrp unless the
-- 
2.7.4
