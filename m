From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH V3 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag to IPV6_FL_A_GET
Date: Fri, 17 Jan 2014 00:53:56 +0100
Message-ID: <20140116235356.GF17529@order.stressinduktion.org>
References: <1389889158-1710-1-git-send-email-florent.fourcot@enst-bretagne.fr> <20140116234103.GE17529@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44035 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaAPXx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 18:53:57 -0500
Content-Disposition: inline
In-Reply-To: <20140116234103.GE17529@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 12:41:03AM +0100, Hannes Frederic Sowa wrote:
> On Thu, Jan 16, 2014 at 05:19:16PM +0100, Florent Fourcot wrote:
> > diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
> > index cbc9351..55823f1 100644
> > --- a/net/ipv6/ip6_flowlabel.c
> > +++ b/net/ipv6/ip6_flowlabel.c
> > @@ -486,6 +486,11 @@ int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq)
> >  	struct ipv6_pinfo *np = inet6_sk(sk);
> >  	struct ipv6_fl_socklist *sfl;
> >  
> > +	if (np->repflow) {
> > +		freq->flr_label = np->flow_label;
> > +		return 0;
> > +	}
> > +
> >  	rcu_read_lock_bh();
> 
> I am still not sure if we should allow quering the label on repflow, if sender
> can change it and we don't update the np->flow_label.

Disregard this comment, it was wrong.

Sorry,

  Hannes
