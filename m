From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v2 PATCH 1/2] NETFILTER module xt_hmark new target for HASH
 based fw
Date: Tue, 15 Nov 2011 11:01:00 +0100
Message-ID: <20111115100100.GB29506@1984>
References: <0hivdsb.f18682ec9367f08c76301d993553f1b8@obelix.schillstrom.com>
 <20111108105110.GA15798@1984>
 <20111113170528.GB16851@1984>
 <201111141019.43423.hans@schillstrom.com>
 <alpine.LNX.2.01.1111141237410.26961@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Schillstrom <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45019 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754468Ab1KOKBC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 05:01:02 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1111141237410.26961@frira.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 12:38:28PM +0100, Jan Engelhardt wrote:
> On Monday 2011-11-14 10:19, Hans Schillstrom wrote:
> 
> >
> >On Sunday, November 13, 2011 18:05:28 Pablo Neira Ayuso wrote:
> >> BTW, I think you should split xt_HMARK to ipt_HMARK and ip6t_HMARK
> >> (see recent Florian Westphal patches regarding reserve lookup for
> >> instance).
> >> 
> >> The IPv4 and IPv6 parts for HMARK look so different that I don't think
> >> it makes sense to keep them into one single xt_HMARK thing with all
> >> those conditional ifdefs for IPV6.
> >>
> >Ok I'll do that, for some reason a thought it was better with one module.
> 
> So do I. The module overhead is so much larger.

Yes, it will if both modules are loaded.

I think it depends, if you only load IPv4 support, the overhead will
be smaller than having everything into one module.

But I'm open to more discussion on this, of course.
