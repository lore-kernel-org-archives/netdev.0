From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch] netfilter: potential NULL dereference in
 get_inner_hdr()
Date: Mon, 14 May 2012 10:22:50 +0200
Message-ID: <20120514082250.GB9524@1984>
References: <20120512110003.GB19472@elgon.mountain>
 <20120514.033853.1089019132135043947.davem@davemloft.net>
 <1336981995.8512.56.camel@edumazet-glaptop>
 <201205141000.12140.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201205141000.12140.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 10:00:00AM +0200, Hans Schillstrom wrote:
> > 
> > http://lwn.net/Articles/205624/
> > 
> > make C=2 CF=-D__CHECK_ENDIAN__ net/netfilter/xt_HMARK.o
> >   CHECK   net/netfilter/xt_HMARK.c
> > net/netfilter/xt_HMARK.c:87:21: warning: incorrect type in assignment (different base types)
> > net/netfilter/xt_HMARK.c:87:21:    expected unsigned short [unsigned] [usertype] src
> > net/netfilter/xt_HMARK.c:87:21:    got restricted __be16 [usertype] all
[...]
> 
> Thanks 
> I'll try to fix the warnings

Ok, wait for that patch, thanks.
