From: jamal <hadi@cyberus.ca>
Subject: Re: |PATCH net-next-2.6] ifb: use netif_receive_skb() instead of
 netif_rx()
Date: Wed, 15 Dec 2010 07:49:23 -0500
Message-ID: <1292417363.2067.17.camel@mojatatu>
References: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com>
	 <1292397202.2377.13.camel@edumazet-laptop>
	 <AANLkTi=TuZNTXTBxmLqu0yyF=f0xM3CQyr_stRHerv6r@mail.gmail.com>
	 <1292402398.3427.6.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:51575 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603Ab0LOMt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 07:49:26 -0500
Received: by ywl5 with SMTP id 5so991965ywl.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 04:49:26 -0800 (PST)
In-Reply-To: <1292402398.3427.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-15 at 09:39 +0100, Eric Dumazet wrote:
> In ri_tasklet(), we run from softirq, so can directly handle packet
> through netif_receive_skb() instead of netif_rx().
> There is no risk of recursion.

Eric, did you do at least a simple test on this one? 
It used to be problematic (I cant remember why or
what use case was problematic).

cheers,
jamal

