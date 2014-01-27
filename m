From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 27 Jan 2014 09:36:06 +0100
Message-ID: <20140127083606.GA30123@breakpoint.cc>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
 <1390810971-23959-2-git-send-email-fw@strlen.de>
 <20140127.003403.165822194531743765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:35588 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753597AbaA0IgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 03:36:07 -0500
Content-Disposition: inline
In-Reply-To: <20140127.003403.165822194531743765.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Mon, 27 Jan 2014 09:22:51 +0100
> > Changes since V2:
> >  - make this thing apply to current -net tree
> >  - kill unused variables in ip_forward/ip6_output
> 
> Still need changes.
> > +	return skb_gso_network_seglen(skb) > dst_mtu(skb_dst(skb));
> 
> You can't use dst_mtu() directly, in order to be consistent with the
> rest of the forwarding code in this file you must use something like:
> 
> >  	mtu = ip_dst_mtu_maybe_forward(&rt->dst, true);

You're right of course.

Sorry.  I will fix this up and NOT resend soon, its clear I need
to do more homework (aka follow Hannes PMTU changes).

Expect a V4 in a couple of hours.
