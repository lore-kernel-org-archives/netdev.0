From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 0/2] SUNRPC: make /proc helpers network-namespace-aware
Date: Tue, 06 Dec 2011 16:42:27 +0300
Message-ID: <20111206123748.15702.93290.stgit@localhost6.localdomain6>
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

This is one more precursor patch set. Both patches in the series will be used
later for creating /proc entries for NFS and NFSd statistics per network
namespace context.

The following series consists of:

---

Stanislav Kinsbursky (2):
      SUNRPC: register RPC stats /proc entries in passed network namespace context
      SUNRPC: register service stats /proc entries in passed network namespace context


 fs/nfs/inode.c               |    6 +++---
 fs/nfsd/stats.c              |    5 +++--
 include/linux/sunrpc/stats.h |   16 ++++++++--------
 net/sunrpc/stats.c           |   21 +++++++++++----------
 4 files changed, 25 insertions(+), 23 deletions(-)
