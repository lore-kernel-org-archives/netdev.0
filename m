From: Wanlong Gao <wanlong.gao@gmail.com>
Subject: [PATCH] drivers:connector:remove an unused variable *tracer*
Date: Sun, 24 Jul 2011 11:06:29 +0800
Message-ID: <1311476789-3858-1-git-send-email-wanlong.gao@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wanlong Gao <gaowanlong@cn.fujitsu.com>
To: zbr@ioremap.net, Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:52006 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159Ab1GXDIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 23:08:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wanlong Gao <gaowanlong@cn.fujitsu.com>

The variable 'tracer' never be used, so remove it.
Added by f701e5b73a1a79ea62ffd45d9e2bed4c7d5c1fd2.

Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
---
 drivers/connector/cn_proc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 281902d..0debc17 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -173,7 +173,6 @@ void proc_ptrace_connector(struct task_struct *task, int ptrace_id)
 	struct proc_event *ev;
 	struct timespec ts;
 	__u8 buffer[CN_PROC_MSG_SIZE];
-	struct task_struct *tracer;
 
 	if (atomic_read(&proc_event_num_listeners) < 1)
 		return;
-- 
1.7.4.1

