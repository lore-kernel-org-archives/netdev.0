From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 10/12] [IPv6]: Use rtnl registration interface
Date: Wed, 21 Mar 2007 13:43:22 +0100
Message-ID: <20070321124322.GW521@postel.suug.ch>
References: <20070321000553.070942307@lsx.localdomain> <20070321000710.549330036@lsx.localdomain> <20070321.020137.109232015.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:47402 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727AbXCUMnD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 08:43:03 -0400
Content-Disposition: inline
In-Reply-To: <20070321.020137.109232015.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2007-03-21 02:01
> In article <20070321000710.549330036@lsx.localdomain> (at Wed, 21 Mar 2007 01:06:03 +0100), Thomas Graf <tgraf@suug.ch> says:
> 
> > -static int
> > -inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
> > +static int nl_addr_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
> >  {
> >  	struct ifaddrmsg *ifm;
> 
> I'm rather not favor changing function names here...

I was trying to achieve consistent naming among all message handlers.
All these functions are static with a single reference.
