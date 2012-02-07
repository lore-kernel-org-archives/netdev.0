From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] NFS: fix nfs4_find_client_sessionid() arguments list
Date: Tue, 07 Feb 2012 19:53:19 +0400
Message-ID: <20120207155309.30133.18889.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's not compilable in case of CONFIG_NFS_V4_1 is not set.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index f0dacad..5b9d201 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1266,7 +1266,7 @@ nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 #else /* CONFIG_NFS_V4_1 */
 
 struct nfs_client *
-nfs4_find_client_sessionid(const struct sockaddr *addr,
+nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 			   struct nfs4_sessionid *sid)
 {
 	return NULL;
