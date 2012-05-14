From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [patch] netfilter: potential NULL dereference in get_inner_hdr()
Date: Mon, 14 May 2012 10:00:00 +0200
Message-ID: <201205141000.12140.hans.schillstrom@ericsson.com>
References: <20120512110003.GB19472@elgon.mountain> <20120514.033853.1089019132135043947.davem@davemloft.net> <1336981995.8512.56.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336981995.8512.56.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 14 May 2012 09:53:15 Eric Dumazet wrote:
> On Mon, 2012-05-14 at 03:38 -0400, David Miller wrote:
> 
> > He said what he's using, "sparse", the semantic parser, which
> > is largely arch agnostic.
> > 
> > I guarantee you will see the warnings if you run it on your
> > system on this code.
> 
> Some more info :
> 
> http://lwn.net/Articles/205624/
> 
> make C=2 CF=-D__CHECK_ENDIAN__ net/netfilter/xt_HMARK.o
>   CHECK   net/netfilter/xt_HMARK.c
> net/netfilter/xt_HMARK.c:87:21: warning: incorrect type in assignment (different base types)
> net/netfilter/xt_HMARK.c:87:21:    expected unsigned short [unsigned] [usertype] src
> net/netfilter/xt_HMARK.c:87:21:    got restricted __be16 [usertype] all
> net/netfilter/xt_HMARK.c:88:21: warning: incorrect type in assignment (different base types)
> net/netfilter/xt_HMARK.c:88:21:    expected unsigned short [unsigned] [usertype] dst
> net/netfilter/xt_HMARK.c:88:21:    got restricted __be16 [usertype] all
> net/netfilter/xt_HMARK.c:170:27: warning: incorrect type in argument 2 (different signedness)
> net/netfilter/xt_HMARK.c:170:27:    expected int *offset
> net/netfilter/xt_HMARK.c:170:27:    got unsigned int *<noident>
> net/netfilter/xt_HMARK.c:181:28: warning: incorrect type in argument 1 (different base types)
> net/netfilter/xt_HMARK.c:181:28:    expected unsigned int const [usertype] *addr32
> net/netfilter/xt_HMARK.c:181:28:    got restricted __be32 *<noident>
> net/netfilter/xt_HMARK.c:182:28: warning: incorrect type in argument 1 (different base types)
> net/netfilter/xt_HMARK.c:182:28:    expected unsigned int const [usertype] *addr32
> net/netfilter/xt_HMARK.c:182:28:    got restricted __be32 *<noident>
> net/netfilter/xt_HMARK.c:261:9: warning: invalid assignment: &=
> net/netfilter/xt_HMARK.c:261:9:    left side has type unsigned int
> net/netfilter/xt_HMARK.c:261:9:    right side has type restricted __be32
> net/netfilter/xt_HMARK.c:262:9: warning: invalid assignment: &=
> net/netfilter/xt_HMARK.c:262:9:    left side has type unsigned int
> net/netfilter/xt_HMARK.c:262:9:    right side has type restricted __be32
> 

Thanks 
I'll try to fix the warnings

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
