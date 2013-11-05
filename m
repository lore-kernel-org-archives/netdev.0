From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 2/4] ipv6: enable IPV6_FLOWLABEL_MGR for getsockopt
Date: Tue, 5 Nov 2013 17:22:25 +0100
Message-ID: <20131105162225.GI8832@order.stressinduktion.org>
References: <1383661738-6083-1-git-send-email-florent.fourcot@enst-bretagne.fr> <1383661738-6083-2-git-send-email-florent.fourcot@enst-bretagne.fr> <20131105160838.GH8832@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51079 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838Ab3KEQW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 11:22:26 -0500
Content-Disposition: inline
In-Reply-To: <20131105160838.GH8832@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 05, 2013 at 05:08:38PM +0100, Hannes Frederic Sowa wrote:
> On Tue, Nov 05, 2013 at 03:28:56PM +0100, Florent Fourcot wrote:
> > +	spin_lock_bh(&ip6_fl_lock);
> > +	rcu_read_lock_bh();
> > +
> > +	for_each_sk_fl_rcu(np, sfl) {
> > +		if (sfl->fl->label == (np->flow_label & IPV6_FLOWLABEL_MASK)) {
> 
> The iteration is protected by rcu, so need to take the ip6_fl_lock. We should
                                        ^no                         ^ here.

Sorry,

  Hannes
