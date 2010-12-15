From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: |PATCH net-next-2.6] ifb: use netif_receive_skb() instead of
 netif_rx()
Date: Wed, 15 Dec 2010 15:21:36 +0100
Message-ID: <1292422896.3427.251.camel@edumazet-laptop>
References: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com>
	 <1292397202.2377.13.camel@edumazet-laptop>
	 <AANLkTi=TuZNTXTBxmLqu0yyF=f0xM3CQyr_stRHerv6r@mail.gmail.com>
	 <1292402398.3427.6.camel@edumazet-laptop>
	 <1292417363.2067.17.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:34268 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650Ab0LOOVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 09:21:42 -0500
Received: by fxm18 with SMTP id 18so2083230fxm.2
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 06:21:41 -0800 (PST)
In-Reply-To: <1292417363.2067.17.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 07:49 -0500, jamal a =C3=A9cri=
t :
> On Wed, 2010-12-15 at 09:39 +0100, Eric Dumazet wrote:
> > In ri_tasklet(), we run from softirq, so can directly handle packet
> > through netif_receive_skb() instead of netif_rx().
> > There is no risk of recursion.
>=20
> Eric, did you do at least a simple test on this one?=20
> It used to be problematic (I cant remember why or
> what use case was problematic).

Yes, I run SFQ / IFB right now on my dev machine, and found SFQ bugs by
the way ;)



