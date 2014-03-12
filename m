From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] cgroup: Provide empty definition of task_cgroup_path()
Date: Wed, 12 Mar 2014 14:45:41 -0400
Message-ID: <1394649942-5854-2-git-send-email-vgoyal@redhat.com>
References: <1394649942-5854-1-git-send-email-vgoyal@redhat.com>
Cc: ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394649942-5854-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Compilation with !CONFIG_CGROUP fails for task_cgroup_path() user. So
provide an emtpy definition.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/cgroup.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 9450f02..bf40adb 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -869,6 +869,8 @@ static inline int cgroup_attach_task_all(struct task_struct *from,
 	return 0;
 }
 
+static inline int task_cgroup_path(struct task_struct *task, char *buf, size_t buflen) {return 0;}
+
 #endif /* !CONFIG_CGROUPS */
 
 #endif /* _LINUX_CGROUP_H */
-- 
1.8.5.3
