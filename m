From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 7/7] rtnetlink: rtnl_have_link_slave_info
 doesn't need rtnl
Date: Thu, 21 Sep 2017 19:31:05 +0200
Message-ID: <20170921173105.GG15946@breakpoint.cc>
References: <20170921165902.10746-1-fw@strlen.de>
 <20170921165902.10746-8-fw@strlen.de>
 <b645a22f-9153-b327-8995-2b140cff59a0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:39706 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752254AbdIURe0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 13:34:26 -0400
Content-Disposition: inline
In-Reply-To: <b645a22f-9153-b327-8995-2b140cff59a0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsahern@gmail.com> wrote:
> On 9/21/17 10:59 AM, Florian Westphal wrote:
> > @@ -539,6 +543,8 @@ static int rtnl_link_slave_info_fill(struct sk_buff *skb,
> >  	struct nlattr *slave_data;
> >  	int err;
> >  
> > +	ASSERT_RTNL();
> > +
[..]
master_dev = netdev_master_upper_dev_get((struct net_device *) dev);

> Since rtnl_link_slave_info_fill and rtnl_link_info_fill are only called
> by rtnl_link_fill and rtnl_link_fill is only called rtnl_fill_ifinfo
> which as the ASSERT_RTNL why add to these lower functions as well?

I'll remove this patch in v2 and will hold it back in my private queue;
these serve more as a reminder/TODO for myself rather than anything else.
