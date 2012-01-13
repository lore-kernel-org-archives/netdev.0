From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v2 0/4] SUNRPC: register services with per-net rpcbind
Date: Fri, 13 Jan 2012 14:02:31 +0400
Message-ID: <20120113095121.12259.52250.stgit@localhost6.localdomain6>
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

This patch-set was created in context of clone of git branch:
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
head: devel

v2:
1) Rebased on up-to-date state ("devel" head).
2) 3 patches from previous series:
a) [1/7] "SUNRPC: create rpcbind client in passed network namespace context"
b) [2/7] "SUNRPC: register rpcbind programs in passed network namespase context"
c) [4/7] "SUNRPC: parametrize local rpcbind clients creation with net ns"
moved to series:
[PATCH v5 0/6] SUNRPC: rcbind clients virtualization

This patch set makes service registered with per-net rpcbind and required for
making Lockd and NFSd services able to handle requests from and to different
network namespaces.

The following series consists of:

---

Stanislav Kinsbursky (4):
      SUNRPC: use proper network namespace in rpcbind RPCBPROC_GETADDR procedure
      SUNRPC: pass network namespace to service registering routines
      SUNRPC: register service on creation in current network namespace
      SUNRPC: unregister service on creation in current network namespace


 fs/nfsd/nfssvc.c           |    4 +--
 include/linux/sunrpc/svc.h |   11 ++++----
 net/sunrpc/rpcb_clnt.c     |    3 +-
 net/sunrpc/svc.c           |   61 ++++++++++++++++++++++++--------------------
 net/sunrpc/svcsock.c       |    3 +-
 5 files changed, 45 insertions(+), 37 deletions(-)

-- 
Signature
