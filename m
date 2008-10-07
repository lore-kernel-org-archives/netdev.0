From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [net-next PATCH 10/16] Don't lookup the socket if there's a
	socket attached to the skb
Date: Tue, 7 Oct 2008 09:36:57 -0300
Message-ID: <20081007123657.GC29610@ghostprotocols.net>
References: <20081001142431.4893.69772.stgit@este> <20081001.075040.135314845.davem@davemloft.net> <1222875500.7492.6.camel@este> <20081001.085104.193726318.davem@davemloft.net> <1222962200.14079.19.camel@este> <20081002170935.GE17843@ghostprotocols.net> <1223024268.8912.2.camel@este> <20081003134747.GH17843@ghostprotocols.net> <1223364984.35518.3.camel@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1223364984.35518.3.camel@nessa.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Oct 07, 2008 at 09:36:24AM +0200, KOVACS Krisztian escreveu:
> Hi,
> 
> On Fri, 2008-10-03 at 10:47 -0300, Arnaldo Carvalho de Melo wrote:
> > [...] 
> > > > Why don't you add it to __inet6_lookup, __inet6_lookup and the udp_lib
> > > > lookup routines? And please rename it to skb_steal_sock, as it acts on a
> > > > skb, not on a sock.
> > > 
> > > Those functions don't have access to the skb so unless we change the
> > > signature they won't be able to steal the reference.
> > 
> > Indeed, but we should try to have the main TCP code flow clean, ditto for
> > DCCP, free of such details, so after this activitity settles down I'll
> > submit something like the patch below.
> > 
> > If Dave agrees and you feel like merging it on your current patchset,
> > feel free to do it.
> 
> Ok, I'll pick this up. Didn't compile because of missing includes in
> inet_hashtables.h but I've fixed it.
> 
> -- 
> KOVACS Krisztian 
> 
> 
> inet_hashtables: Add inet_lookup_skb helpers
> 
> To be able to use the cached socket reference in the skb during input
> processing we add a new set of lookup functions that receive the skb on
> their argument list.
> 
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>

Thanks a lot!

- Arnaldo
