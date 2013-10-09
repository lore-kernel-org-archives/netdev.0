From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: fix build errors if ipv6 is disabled
Date: Wed, 09 Oct 2013 03:05:31 -0700
Message-ID: <1381313131.4971.12.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381295165.4971.7.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131009.025231.608686215035548132.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:38955 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757054Ab3JIKFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 06:05:35 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so679961pbc.18
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 03:05:35 -0700 (PDT)
In-Reply-To: <20131009.025231.608686215035548132.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-09 at 02:52 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 08 Oct 2013 22:06:05 -0700
> 
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +	if (sk->sk_family == AF_INET6 && !ipv6_addr_any(&sk->sk_v6_rcv_saddr)
> > +		sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
> > +#endif
> 
> Would you mind testing this with ipv6 enabled again? :-/

Humpf :(
