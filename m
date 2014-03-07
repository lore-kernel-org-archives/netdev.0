From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [nf-next PATCH V3 0/5] netfilter: conntrack: optimization,
 remove central spinlock
Date: Fri, 7 Mar 2014 11:45:36 +0100
Message-ID: <20140307104536.GA11140@localhost>
References: <20140303134319.2615.9293.stgit@dragon>
 <20140303.160046.1024219314107578405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brouer@redhat.com, netfilter-devel@vger.kernel.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, fw@strlen.de,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46278 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751206AbaCGKpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 05:45:42 -0500
Content-Disposition: inline
In-Reply-To: <20140303.160046.1024219314107578405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2014 at 04:00:46PM -0500, David Miller wrote:
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Mon, 03 Mar 2014 14:44:16 +0100
> 
> > This patchset change the conntrack locking and provides a huge
> > performance improvements.
> > 
> > This patchset is based upon Eric Dumazet's proposed patch:
> >   http://thread.gmane.org/gmane.linux.network/268758/focus=47306
> > I have in agreement with Eric Dumazet, taken over this patch (and
> > turned it into a entire patchset).
> > 
> > Primary focus is to remove the central spinlock nf_conntrack_lock.
> > This requires several steps to be acheived.
>  ...
> 
> For series:
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Applied, thanks everyone.
