From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 0/7] SUNRPC: register services with per-net rpcbind
Date: Thu, 15 Dec 2011 19:59:42 +0300
Message-ID: <20111215155252.2434.39434.stgit@localhost6.localdomain6>
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

This patch set makes service registered with per-net rpcbind and required for
making Lockd and NFSd services able to handle requests from and to different
network namespaces.

The following series consists of:

---

Stanislav Kinsbursky (7):
      SUNRPC: create rpcbind client in passed network namespace context
      SUNRPC: register rpcbind programs in passed network namespase context
      SUNRPC: use proper network namespace in rpcbind RPCBPROC_GETADDR procedure
      SUNRPC: parametrize local rpcbind clients creation with net ns
      SUNRPC: pass network namespace to service registering routines
      SUNRPC: register service on creation in current network namespace
      SUNRPC: unregister service on creation in current network namespace


 fs/nfsd/nfssvc.c            |    4 +--
 include/linux/sunrpc/clnt.h |    9 ++++--
 include/linux/sunrpc/svc.h  |   11 ++++----
 net/sunrpc/rpcb_clnt.c      |   29 +++++++++++---------
 net/sunrpc/svc.c            |   61 +++++++++++++++++++++++--------------------
 net/sunrpc/svcsock.c        |    3 +-
 6 files changed, 63 insertions(+), 54 deletions(-)

-- 
Signature
