From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 0/4] make function arg and structures as const
Date: Tue, 17 Oct 2017 18:14:22 +0200
Message-ID: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, davem@davemloft.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the function argument as const. After thing change, make
the cache_detail structures as const.

Bhumika Goyal (4):
  sunrpc: make the function arg as const
  NFS: make cache_detail structures const
  NFSD: make cache_detail structures const
  SUNRPC: make cache_detail structures const

 fs/nfs/dns_resolve.c              | 2 +-
 fs/nfsd/export.c                  | 4 ++--
 fs/nfsd/nfs4idmap.c               | 4 ++--
 include/linux/sunrpc/cache.h      | 2 +-
 net/sunrpc/auth_gss/svcauth_gss.c | 4 ++--
 net/sunrpc/cache.c                | 2 +-
 net/sunrpc/svcauth_unix.c         | 4 ++--
 7 files changed, 11 insertions(+), 11 deletions(-)

-- 
1.9.1
