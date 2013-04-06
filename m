From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 00/51] netfilter updates for net-next
Date: Sat, 6 Apr 2013 15:52:44 +0200
Message-ID: <20130406135244.GA17634@localhost>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
 <alpine.LFD.2.00.1304061612270.1627@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43619 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422919Ab3DFNxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 09:53:09 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1304061612270.1627@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian,

On Sat, Apr 06, 2013 at 04:14:54PM +0300, Julian Anastasov wrote:
> > Julian Anastasov (33):
> 
> 	Is the "net: add skb_dst_set_noref_force" change
> missing here?

It's there, but I forgot to include it in this pull request email:

http://1984.lsi.us.es/git/nf-next/commit/?id=932bc4d7a53ba418de67fdab533248df5b36c752

> >   ipvs: avoid routing by TOS for real server
> >   ipvs: prefer NETDEV_DOWN event to free cached dsts
> >   ipvs: convert the IP_VS_XMIT macros to functions
> >   ipvs: rename functions related to dst_cache reset
> >   ipvs: no need to reroute anymore on DNAT over loopback
> >   ipvs: do not use skb_share_check
> >   ipvs: consolidate all dst checks on transmit in one place
> >   ipvs: optimize dst usage for real server
> >   ipvs: convert app locks
> >   ipvs: remove rs_lock by using RCU
> >   ipvs: convert locks used in persistence engines
> >   ipvs: convert connection locking
> >   ipvs: reorder keys in connection structure
> >   ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new
> >   ipvs: change ip_vs_sched_lock to mutex
> >   ipvs: preparations for using rcu in schedulers
> >   ipvs: add ip_vs_dest_hold and ip_vs_dest_put
> >   ipvs: convert dh scheduler to rcu
> >   ipvs: convert lblc scheduler to rcu
> >   ipvs: convert lblcr scheduler to rcu
> >   ipvs: convert lc scheduler to rcu
> >   ipvs: convert nq scheduler to rcu
> >   ipvs: convert rr scheduler to rcu
> >   ipvs: convert sed scheduler to rcu
> >   ipvs: convert sh scheduler to rcu
> >   ipvs: convert wlc scheduler to rcu
> >   ipvs: convert wrr scheduler to rcu
> >   ipvs: reorganize dest trash
> >   ipvs: do not expect result from done_service
> >   ipvs: convert sched_lock to spin lock
> >   ipvs: convert dests to rcu
> >   ipvs: convert services to rcu
> >   ipvs: do not disable bh for long time
