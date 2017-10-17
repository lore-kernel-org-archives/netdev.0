From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/4] make function arg and structures as const
Date: Tue, 17 Oct 2017 12:40:27 -0400
Message-ID: <1508258427.4747.7.camel@redhat.com>
References: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, davem@davemloft.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-10-17 at 18:14 +0200, Bhumika Goyal wrote:
> Make the function argument as const. After thing change, make
> the cache_detail structures as const.
> 
> Bhumika Goyal (4):
>   sunrpc: make the function arg as const
>   NFS: make cache_detail structures const
>   NFSD: make cache_detail structures const
>   SUNRPC: make cache_detail structures const
> 
>  fs/nfs/dns_resolve.c              | 2 +-
>  fs/nfsd/export.c                  | 4 ++--
>  fs/nfsd/nfs4idmap.c               | 4 ++--
>  include/linux/sunrpc/cache.h      | 2 +-
>  net/sunrpc/auth_gss/svcauth_gss.c | 4 ++--
>  net/sunrpc/cache.c                | 2 +-
>  net/sunrpc/svcauth_unix.c         | 4 ++--
>  7 files changed, 11 insertions(+), 11 deletions(-)
> 

Looks pretty straightforward. You can add this to the set:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
