From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [GIT] Networking
Date: Thu, 6 Oct 2016 11:52:35 +1100
Message-ID: <20161006115235.1a89c0da@canb.auug.org.au>
References: <20161005.014437.1946431553783736769.davem@davemloft.net>
        <20161006092947.25ae781c@canb.auug.org.au>
        <CA+55aFzbHD95PMUk4JQfAVkDDRcwzZ6vfvMR60tZnQNSwkDE6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Liping Zhang <liping.zhang@spreadtrum.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:51187 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750873AbcJFAwj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 20:52:39 -0400
In-Reply-To: <CA+55aFzbHD95PMUk4JQfAVkDDRcwzZ6vfvMR60tZnQNSwkDE6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

On Wed, 5 Oct 2016 15:37:17 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
> On Wed, Oct 5, 2016 at 3:29 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >
> > I have been carrying the following merge fix patch (for the merge of
> > the net-next tree with Linus' tree) for a while now which seems to have
> > got missed:  
> 
> Ugh. It doesn't seem to be a merge error, because that double iph
> assignment came from the original patch that introduced this function:
> commit ddc8b6027ad0 ("netfilter: introduce nft_set_pktinfo_{ipv4,
> ipv6}_validate()").

Except that commit effectively moved that function from
net/netfilter/nf_tables_netdev.c to
include/net/netfilter/nf_tables_ipv4.h while commit c73c24849011
("netfilter: nf_tables_netdev: remove redundant ip_hdr assignment")
removed the assignment in the original file (and has been in your tree
since v4.8-rc7) and that is where I originally actually got a conflict.

> So I wouldn't call it a merge error - it just looks like a bug in the
> network layer. So I'm not going to apply your patch even though it
> looks plausible to me, simply because it's outside my area of
> expertise.

no worries.
-- 
Cheers,
Stephen Rothwell
