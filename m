From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] netfilter: conntrack: Fix UP builds
Date: Tue, 18 Mar 2014 08:15:12 +0100
Message-ID: <20140318081512.63d02c38@redhat.com>
References: <1395088673.9668.65.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140317.171507.1078092240612029454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, pablo@netfilter.org,
	netdev@vger.kernel.org, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21419 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751915AbaCRHP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:15:26 -0400
In-Reply-To: <20140317.171507.1078092240612029454.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Mar 2014 17:15:07 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 17 Mar 2014 13:37:53 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > ARRAY_SIZE(nf_conntrack_locks) is undefined if spinlock_t is an
> > empty structure. Replace it by CONNTRACK_LOCKS
> > 
> > Fixes: 93bb0ceb75be ("netfilter: conntrack: remove central spinlock nf_conntrack_lock")
> > Reported-by: kbuild test robot <fengguang.wu@intel.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > ---
> > David, you might merge this asap instead of going through Pablo queue ?
> 
> Sure, applied, thanks Eric.

Thanks for fixing this Eric :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
