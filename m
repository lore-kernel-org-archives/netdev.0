From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] netem: add cell concept to simulate special
 MAC behavior
Date: Mon, 12 Dec 2011 09:18:58 -0800
Message-ID: <20111212091858.07a916fc@nehalam.linuxnetplumber.net>
References: <1323530144-20014-1-git-send-email-hagen@jauu.net>
	<1323535432.4016.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org,
	davem@davemloft.net, Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36887 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023Ab1LLRTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Dec 2011 12:19:01 -0500
In-Reply-To: <1323535432.4016.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 10 Dec 2011 17:43:52 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> >  struct tc_netem_rate {
> >  	__u32	rate;	/* byte/s */
> > +	__s32	packet_overhead;
> > +	__u32	cell_size;
> > +	__s32	cell_overhead;  
> 
> Adding fields in existing structure is convenient, but this means a
> previous tc binary wont work anymore.

In this case it is ok because there  has not been a release
using this structure yet.
