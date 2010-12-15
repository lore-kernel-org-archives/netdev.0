From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: |PATCH net-next-2.6] ifb: use netif_receive_skb() instead of
 netif_rx()
Date: Wed, 15 Dec 2010 08:14:47 -0800
Message-ID: <20101215081447.64081885@nehalam>
References: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com>
	<1292397202.2377.13.camel@edumazet-laptop>
	<AANLkTi=TuZNTXTBxmLqu0yyF=f0xM3CQyr_stRHerv6r@mail.gmail.com>
	<1292402398.3427.6.camel@edumazet-laptop>
	<1292417363.2067.17.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37541 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752490Ab0LOQPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 11:15:15 -0500
In-Reply-To: <1292417363.2067.17.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Dec 2010 07:49:23 -0500
jamal <hadi@cyberus.ca> wrote:

> On Wed, 2010-12-15 at 09:39 +0100, Eric Dumazet wrote:
> > In ri_tasklet(), we run from softirq, so can directly handle packet
> > through netif_receive_skb() instead of netif_rx().
> > There is no risk of recursion.
> 
> Eric, did you do at least a simple test on this one? 
> It used to be problematic (I cant remember why or
> what use case was problematic).

Only risk is stack overflow.
