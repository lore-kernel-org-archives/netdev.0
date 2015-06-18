From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] x_table: align per cpu xt_counter
Date: Thu, 18 Jun 2015 12:50:31 +0200
Message-ID: <20150618105031.GB3751@salvia>
References: <1434417013.27504.161.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150618.034326.1579688535859905135.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57766 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825AbbFRKpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 06:45:11 -0400
Content-Disposition: inline
In-Reply-To: <20150618.034326.1579688535859905135.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2015 at 03:43:26AM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 15 Jun 2015 18:10:13 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Let's force a 16 bytes alignment on xt_counter percpu allocations,
> > so that bytes and packets sit in same cache line.
> > 
> > xt_counter being exported to user space, we cannot add __align(16) on
> > the structure itself.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Florian Westphal <fw@strlen.de>
> 
> Pablo, I assume you will take this.

Yes, I'll prepare another pull request for you along today.
