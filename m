From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 5/7] rtnetlink: add helper to dump vf information
Date: Thu, 21 Sep 2017 19:25:51 +0200
Message-ID: <20170921172551.GF15946@breakpoint.cc>
References: <20170921165902.10746-1-fw@strlen.de>
 <20170921165902.10746-6-fw@strlen.de>
 <bdc39ebf-e934-16ce-0834-e0795774a656@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:39550 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752281AbdIUR3M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 13:29:12 -0400
Content-Disposition: inline
In-Reply-To: <bdc39ebf-e934-16ce-0834-e0795774a656@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsahern@gmail.com> wrote:
> On 9/21/17 10:59 AM, Florian Westphal wrote:
> > similar to earlier patches, split out more parts of this function to
> > better see what is happening and where we assume rtnl is locked.

[..]

> > +static noinline_for_stack int rtnl_fill_vf(struct sk_buff *skb,
> > +					   struct net_device *dev,
> > +					   u32 ext_filter_mask)
[..]
> > +static int noinline rtnl_fill_link_netnsid(struct sk_buff *skb,
> > +				  const struct net_device *dev)
[..]
> >  static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
> 
> Similarly for this patch -- subject references vf helper yet the code
> changes flips netnsid as well.

Right, anomly due to improper squash-merge.
I'll send a v2 tomorrow (giving more time for others to comment).
