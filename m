From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 01/27] afnetns: add CLONE_NEWAFNET flag
Date: Mon, 13 Mar 2017 00:01:25 +0100
Message-ID: <20170312230151.5185-2-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:46200 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935581AbdCLXCB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:01 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 43F6E20685
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:54 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id AB0D22436A
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:53 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new clone flag. It will be used if a clone should also
open up a new afnetns namespace. The only restriction placed on this new
flag, is, that it cannot be used together with CLONE_NEWNET.

The previous usage of flag 0x00001000 was used for CLONE_IDLETASK until
2004. It was only allowed to be used by the kernel, thus I consider its
usage safe.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/uapi/linux/sched.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/sched.h b/include/uapi/linux/sched.h
index 5f0fe019a7204e..b48dea58f55524 100644
--- a/include/uapi/linux/sched.h
+++ b/include/uapi/linux/sched.h
@@ -9,6 +9,7 @@
 #define CLONE_FS	0x00000200	/* set if fs info shared between processes */
 #define CLONE_FILES	0x00000400	/* set if open files shared between processes */
 #define CLONE_SIGHAND	0x00000800	/* set if signal handlers and blocked signals shared */
+#define CLONE_NEWAFNET	0x00001000	/* Clone new afnet context */
 #define CLONE_PTRACE	0x00002000	/* set if we want to let tracing continue on the child too */
 #define CLONE_VFORK	0x00004000	/* set if the parent wants the child to wake it up on mm_release */
 #define CLONE_PARENT	0x00008000	/* set if we want to have the same parent as the cloner */
-- 
2.9.3
