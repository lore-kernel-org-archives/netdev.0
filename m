From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 0/5] SUNRPC: make caches network namespace aware
Date: Thu, 19 Jan 2012 18:48:56 +0400
Message-ID: <20120119144517.9957.59143.stgit@localhost6.localdomain6>
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

One more step towards to "NFS in container".
With this patch set caches are allocated per network namespace.

The following series consists of:

---

Stanislav Kinsbursky (5):
      SUNRPC: cache creation and destruction routines introduced
      SUNRPC: create unix gid cache per network namespace
      SUNRPC: create GSS auth cache per network namespace
      SUNRPC: ip map cache per network namespace cleanup
      SUNRPC: generic cache register routines removed


 include/linux/sunrpc/cache.h       |    6 +
 include/linux/sunrpc/svcauth_gss.h |    2 
 net/sunrpc/auth_gss/auth_gss.c     |   21 +++++
 net/sunrpc/auth_gss/svcauth_gss.c  |  161 +++++++++++++++++++++++++-----------
 net/sunrpc/cache.c                 |   34 ++++++--
 net/sunrpc/netns.h                 |    3 +
 net/sunrpc/sunrpc_syms.c           |   15 ++-
 net/sunrpc/svcauth_unix.c          |  107 ++++++++++++++----------
 8 files changed, 240 insertions(+), 109 deletions(-)
