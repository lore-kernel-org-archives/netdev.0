From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH] cgroup: net_cls: Include missing header with sock_update_classid() definition
Date: Fri, 14 Sep 2012 16:33:04 +0200
Message-ID: <1347633184-26837-3-git-send-email-wagi@monom.org>
References: <1347633184-26837-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Joe Perches <joe@perches.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Rick Jones <rick.jones2@hp.com>,
	Stanislav Kinsbursky <skinsbursky@parallels.com>,
	Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	cgroups@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347633184-26837-1-git-send-email-wagi@monom.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

commit 1f66c0a8833c3974ab6b35edcf4f8585b2f94592
Author: Daniel Wagner <daniel.wagner@bmw-carit.de>
Date:   Wed Sep 12 16:12:01 2012 +0200

    cgroup: net_cls: Move sock_update_classid() declaration to cls_cgroup.h

Claimed that there was only net/socket.c depending on
sock_update_class(). That is not true drivers/net/tun.c needs to
include the cls_cgroup.h header too.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Joe Perches <joe@perches.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Rick Jones <rick.jones2@hp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---

This version is on top of the latest cgroup for-3.7 branch.

 drivers/net/tun.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3a16d4f..9336b82 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -68,6 +68,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/sock.h>
+#include <net/cls_cgroup.h>
 
 #include <asm/uaccess.h>
 
-- 
1.7.12.315.g682ce8b
