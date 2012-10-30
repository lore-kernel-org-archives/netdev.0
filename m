From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 1/8] bridge: bridge port parameters over
 netlink
Date: Tue, 30 Oct 2012 14:00:09 -0700
Message-ID: <20121030140009.067f49fa@nehalam.linuxnetplumber.net>
References: <20121030005731.843020405@vyatta.com>
	<20121030005835.289407930@vyatta.com>
	<50902115.3090005@gurgi.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Tommy S. Christensen" <tsc@gurgi.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59129 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934107Ab2J3VBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 17:01:05 -0400
In-Reply-To: <50902115.3090005@gurgi.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Oct 2012 19:48:53 +0100
"Tommy S. Christensen" <tsc@gurgi.dk> wrote:

> On 10/30/2012 01:57 AM, Stephen Hemminger wrote:
> >
> > -/*
> > - * Change state of port (ie from forwarding to blocking etc)
> > +static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
> > +	[IFLA_BRPORT_STATE]	= { .type = NLA_U8 },
> > +	[IFLA_BRPORT_COST]	= { .type = NLA_U16 },
> > +	[IFLA_BRPORT_PRIORITY]	= { .type = NLA_U32 },
> > +	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
> > +};
> > +
> 
> Hey Stephen
> 
> It seems you've swapped the sizes of COST and PRIORITY in this part.
> 
> -Tommy
> 

Ok, will fix in next version.

One alternative I considered would be to use previously unused IFLA_PRIORITY and IFLA_COST
which would be more generic. But these fields only really matter to bridge.
