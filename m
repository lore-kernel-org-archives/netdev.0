From: Vivek Goyal <vgoyal@redhat.com>
Subject: [PATCH 1/2] cgroup: Provide empty definition of task_cgroup_path()
Date: Wed, 12 Mar 2014 16:46:02 -0400
Message-ID: <1394657163-7472-2-git-send-email-vgoyal@redhat.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
Cc: ssorce@redhat.com, jkaluza@redhat.com, lpoetter@redhat.com,
	kay@redhat.com, Vivek Goyal <vgoyal@redhat.com>
To: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compilation with !CONFIG_CGROUP fails for task_cgroup_path() user. So
provide an emtpy definition.

Signed-off-by: Vivek Goyal <vgoyal@redhat.com>
---
 include/linux/cgroup.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 9450f02..727728c 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -869,6 +869,12 @@ static inline int cgroup_attach_task_all(struct task_struct *from,
 	return 0;
 }
 
+static inline int
+task_cgroup_path(struct task_struct *task, char *buf, size_t buflen)
+{
+	return 0;
+}
+
 #endif /* !CONFIG_CGROUPS */
 
 #endif /* _LINUX_CGROUP_H */
-- 
1.8.5.3
