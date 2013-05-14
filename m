From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Some netfilter compile errors when CONFIG_IPV6=m
Date: Tue, 14 May 2013 05:10:18 +0200
Message-ID: <20130514031018.GA4964@localhost>
References: <1368499552.2507.5.camel@cr0>
 <1368499702.2507.7.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1368499702.2507.7.camel@cr0>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 14, 2013 at 10:48:22AM +0800, Cong Wang wrote:
> On Tue, 2013-05-14 at 10:45 +0800, Cong Wang wrote:
> > net/built-in.o: In function `tproxy_tg_init':
> > /home/wangcong/linux/net/netfilter/xt_TPROXY.c:415: undefined reference
> > to `nf_defrag_ipv6_enable'
> > net/built-in.o: In function `socket_mt_init':
> > /home/wangcong/linux/net/netfilter/xt_socket.c:366: undefined reference
> > to `nf_defrag_ipv6_enable'
> 
> I don't know why we keep an empty definition for
> nf_defrag_ipv6_enable(), so I make a patch to remove it, not sure if it
> makes sense.

It's there to enforce the dependency between nf_conntrack and
nf_defrag. We cannot run nf_conntrack without it.
