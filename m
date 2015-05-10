From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code
 where it belongs
Date: Sun, 10 May 2015 19:59:34 +0200
Message-ID: <20150510175934.GA3799@salvia>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org>
 <1431277170-4618-3-git-send-email-pablo@netfilter.org>
 <554F9946.9040707@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	daniel@iogearbox.net
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44420 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549AbbEJRyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 13:54:54 -0400
Content-Disposition: inline
In-Reply-To: <554F9946.9040707@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 10, 2015 at 10:45:42AM -0700, Alexei Starovoitov wrote:
> On 5/10/15 9:59 AM, Pablo Neira Ayuso wrote:
> >The qdisc ingress filtering code is embedded into the core most likely because
> >at that time we had no RCU in place to define a hook. This is semantically
> >wrong as this violates the most basic rules of encapsulation.
> 
> Yet another attempt to sneak in 'qdisc_ingress_hook' to kill TC ?
> Just add another hook for netfilter. Seriously. Enough of these
> politics.

Absolutely not. I will not kill TC because people like jamal likes it,
and that's more than an argument to me to keep it there.

I have to ask you to stop harassing me all over with non-technical
comments: "evil", "funny", ...

I'm getting quite enough of this, you stop that.

> Again, Daniel's patch accelerates super-critical ingress path even more.
> Care to carefully read it first?

No, Daniel is *not* benchmarking the netif_received_core() with no
filtering at all.
