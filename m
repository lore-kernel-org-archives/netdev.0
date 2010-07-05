From: Michal Humpula <michal.humpula@web4u.cz>
Subject: Re: [PATCH net-next-2.6 v2] ipv6: adding ip_nonlocal_bind option from ipv4
Date: Mon, 5 Jul 2010 13:59:25 +0200
Message-ID: <201007051359.25587.michal.humpula@web4u.cz>
References: <201007051212.31554.michal.humpula@web4u.cz> <1278325832.19358.33.camel@sylph.linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="windows-1250"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hudrydum.cz ([88.208.90.178]:34106 "EHLO hudrydum.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008Ab0GEL73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 07:59:29 -0400
In-Reply-To: <1278325832.19358.33.camel@sylph.linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 05 of July 2010 12:30:32 YOSHIFUJI Hideaki wrote:
> Hello.
> 
> Mails are crossing, but additional comments below.
> 
> Michal Humpula wrote:
> > diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
> > index 1357c57..525edae 100644
> > --- a/kernel/sysctl_binary.c
> > +++ b/kernel/sysctl_binary.c
> > @@ -559,6 +559,7 @@ static const struct bin_table bin_net_ipv6_table[] =
> > {
> > 
> >  	{ CTL_DIR,	NET_IPV6_ROUTE,		"route",	bin_net_ipv6_route_table },
> >  	{ CTL_DIR,	NET_IPV6_ICMP,		"icmp",		bin_net_ipv6_icmp_table },
> >  	{ CTL_INT,	NET_IPV6_BINDV6ONLY,		"bindv6only" },
> > 
> > +	{ CTL_INT,	NET_IPV6_NONLOCAL_BIND,		"ipv6_nonlocal_bind" },
> > 
> >  	{ CTL_INT,	NET_IPV6_IP6FRAG_HIGH_THRESH,	"ip6frag_high_thresh" },
> >  	{ CTL_INT,	NET_IPV6_IP6FRAG_LOW_THRESH,	"ip6frag_low_thresh" },
> >  	{ CTL_INT,	NET_IPV6_IP6FRAG_TIME,		"ip6frag_time" },
> 
> No more binary interface.
> 
> > diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> > index e830cd4..ed59ec4 100644
> > --- a/net/ipv6/af_inet6.c
> > +++ b/net/ipv6/af_inet6.c
> > 
> > @@ -252,6 +252,8 @@ out_rcu_unlock:
> >  	goto out;
> >  
> >  }
> > 
> > +int sysctl_ipv6_nonlocal_bind __read_mostly;
> > +EXPORT_SYMBOL(sysctl_ipv6_nonlocal_bind);
> 
> why?
> 
> In IPv4 it seems to be exported for SCTP. Probably you need to
> look into SCTP as well.
> 
> --yoshfuji

Thanks for review. I should obviously wait a little bit longer before posting the v2.
