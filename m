From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: |PATCH net-next-2.6] ifb: use netif_receive_skb() instead of netif_rx()
Date: Wed, 15 Dec 2010 16:51:25 +0800
Message-ID: <AANLkTi=pMvP_psmwG3bQDkFtvnNcD=BxZEp3cvTEPwnT@mail.gmail.com>
References: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com>
 <1292397202.2377.13.camel@edumazet-laptop> <AANLkTi=TuZNTXTBxmLqu0yyF=f0xM3CQyr_stRHerv6r@mail.gmail.com>
 <1292402398.3427.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:58210 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab0LOIvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 03:51:47 -0500
Received: by fxm18 with SMTP id 18so1752898fxm.2
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 00:51:46 -0800 (PST)
In-Reply-To: <1292402398.3427.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 15, 2010 at 4:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> In ri_tasklet(), we run from softirq, so can directly handle packet
> through netif_receive_skb() instead of netif_rx().
> There is no risk of recursion.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Acked-by: Changli Gao <xiaosuo@gmail.com>


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
