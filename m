From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 2/5] NFS: build fixed in case of NFS_USE_NEW_IDMAPPER is
 undefined
Date: Thu, 26 Jan 2012 15:11:41 +0400
Message-ID: <20120126111141.8386.95788.stgit@localhost6.localdomain6>
References: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/idmap.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index aed3d2e..04f58d4 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -378,6 +378,7 @@ int nfs_map_gid_to_group(const struct nfs_server *server, __u32 gid, char *buf,
 
 #include "nfs4_fs.h"
 #include "internal.h"
+#include "netns.h"
 
 #define IDMAP_HASH_SZ          128
 
