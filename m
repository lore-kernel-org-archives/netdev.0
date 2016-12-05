From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Mon, 5 Dec 2016 22:30:01 +0100
Message-ID: <20161205213001.GA16819@breakpoint.cc>
References: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <1480972006.18162.559.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netfilter-devel@vger.kernel.org, pablo@netfilter.org,
        netdev@vger.kernel.org, daniel@iogearbox.net,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:39576 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751786AbcLEVdR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 16:33:17 -0500
Content-Disposition: inline
In-Reply-To: <1480972006.18162.559.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-12-05 at 15:28 -0500, Willem de Bruijn wrote:
> > From: Willem de Bruijn <willemb@google.com>
> > 
> > Add support for attaching an eBPF object by file descriptor.
> > 
> > The iptables binary can be called with a path to an elf object or a
> > pinned bpf object. Also pass the mode and path to the kernel to be
> > able to return it later for iptables dump and save.
> > 
> > Signed-off-by: Willem de Bruijn <willemb@google.com>
> > ---
> 
> Assuming there is no simple way to get variable matchsize in iptables,
> this looks good to me, thanks.

It should be possible by setting kernel .matchsize to ~0 which
suppresses strict size enforcement.

Its currently only used by ebt_among, but this should work for any xtables
module.
