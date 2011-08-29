From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: RE: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:36:17 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4EE9@SACMVEXC2-PRD.hq.netapp.com>
References: <cover.1314650069.git.joe@perches.com> <8a6378b3fef105983db001fb720c84b669491439.1314650069.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	<linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Neil Brown" <neilb@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <8a6378b3fef105983db001fb720c84b669491439.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Monday, August 29, 2011 5:18 PM
> To: Myklebust, Trond; J. Bruce Fields; Neil Brown
> Cc: David S. Miller; linux-nfs@vger.kernel.org;
netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org
> Subject: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
> 
> Removing unnecessary messages saves code and text.
> 
> Site specific OOM messages are duplications of a generic MM
> out of memory message and aren't really useful, so just
> delete them.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/sunrpc/auth_gss/gss_krb5_crypto.c |   10 ++--------
>  net/sunrpc/auth_gss/gss_krb5_mech.c   |    2 --
>  net/sunrpc/backchannel_rqst.c         |    9 +++------
>  net/sunrpc/clnt.c                     |    3 ---
>  net/sunrpc/rpc_pipe.c                 |    3 +--
>  net/sunrpc/rpcb_clnt.c                |    2 --
>  net/sunrpc/xprtrdma/svc_rdma.c        |    8 ++------
>  net/sunrpc/xprtrdma/transport.c       |    5 +----
>  net/sunrpc/xprtrdma/verbs.c           |   14 --------------
>  net/sunrpc/xprtsock.c                 |    5 +----
>  10 files changed, 10 insertions(+), 51 deletions(-)
> 

Big NACK...

By whose standard are those "not useful"?

Trond
