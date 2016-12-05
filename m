From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Mon, 5 Dec 2016 23:40:51 +0100
Message-ID: <20161205224051.GB16819@breakpoint.cc>
References: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <1480972006.18162.559.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161205213001.GA16819@breakpoint.cc>
 <20161205223415.GA14689@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, Willem de Bruijn <willemb@google.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:39854 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751501AbcLEWoG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 17:44:06 -0500
Content-Disposition: inline
In-Reply-To: <20161205223415.GA14689@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Mon, Dec 05, 2016 at 10:30:01PM +0100, Florian Westphal wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > On Mon, 2016-12-05 at 15:28 -0500, Willem de Bruijn wrote:
> > > > From: Willem de Bruijn <willemb@google.com>
> > > > 
> > > > Add support for attaching an eBPF object by file descriptor.
> > > > 
> > > > The iptables binary can be called with a path to an elf object or a
> > > > pinned bpf object. Also pass the mode and path to the kernel to be
> > > > able to return it later for iptables dump and save.
> > > > 
> > > > Signed-off-by: Willem de Bruijn <willemb@google.com>
> > > > ---
> > > 
> > > Assuming there is no simple way to get variable matchsize in iptables,
> > > this looks good to me, thanks.
> > 
> > It should be possible by setting kernel .matchsize to ~0 which
> > suppresses strict size enforcement.
> > 
> > Its currently only used by ebt_among, but this should work for any xtables
> > module.
> 
> This is likely going to trigger a large rewrite of the core userspace
> iptables codebase, and likely going to pull part of the mess we have
> in ebtables into iptables. So I'd prefer not to follow this path.

Fair enough, I have no objections to the patch.
