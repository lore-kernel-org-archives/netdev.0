From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: Request for -stable inclusion (xt_TCPMSS)
Date: Fri, 16 Jun 2017 12:52:11 +0200
Message-ID: <20170616105211.7byovh3uxlgozyle@alphalink.fr>
References: <20170616074516.yzgd7sqqigjepx37@alphalink.fr>
 <20170616095912.GB1963@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
        netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:41176 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbdFPKwP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 06:52:15 -0400
Content-Disposition: inline
In-Reply-To: <20170616095912.GB1963@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 16, 2017 at 11:59:12AM +0200, Pablo Neira Ayuso wrote:
> Hi Guillaume,
> 
> On Fri, Jun 16, 2017 at 09:45:17AM +0200, Guillaume Nault wrote:
> > Hi David,
> > 
> > Please queue 2638fd0f92d4 ("netfilter: xt_TCPMSS: add more sanity tests on tcph->doff")
> > for -stable.
> > It fixes hard to debug crashes in production, that can be triggered by
> > remote peers.
> 
> What stable kernels you want this in? Does this apply cleanly to them
> all?
> 
I need it (and reviewed/tested it) for 4.9. But the patch applies
cleanly and looks necessary for all stable versions >= 3.16 (not
tested though).

> I can route this for you directly to stable@vger.kernel.org once we
> sort out these questions.
> 
> Thanks!
Great, thanks Pablo. But do you mean I should have Cc-ed
stable@vger.kernel.org directly?
