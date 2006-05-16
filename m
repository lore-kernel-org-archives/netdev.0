From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] netchannel subsystem.
Date: Tue, 16 May 2006 10:59:23 +0400
Message-ID: <20060516065923.GA8649@2ka.mipt.ru>
References: <200605051248.42662.kelly@au.ibm.com> <200605161102.29472.kelly@au.ibm.com> <20060516061909.GA28670@2ka.mipt.ru> <20060515.235712.26771832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, kelly@au1.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:4498 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751568AbWEPG7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 02:59:41 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060515.235712.26771832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2006 at 11:57:12PM -0700, David S. Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Tue, 16 May 2006 10:19:09 +0400
> 
> > +static int netchannel_convert_skb_ipv4(struct sk_buff *skb, struct unetchannel *unc)
> > +{
>  ...
> > +	switch (unc->proto) {
> > +		case IPPROTO_TCP:
>  ...
> > +		case IPPROTO_UDP:
>  ...
> 
> Why do people write code like this?
> 
> Port location is protocol agnostic, there are always 2
> 16-bit ports at beginning of header without exception.
> 
> Without this, ICMP would be useless :-)

And what if we use ESP which would place it's hashed sequence number as
port?

-- 
	Evgeniy Polyakov
