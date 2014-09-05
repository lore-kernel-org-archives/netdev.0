From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] l2tp: fix race while getting PMTU on PPP pseudo-wire
Date: Fri, 5 Sep 2014 14:47:28 -0700
Message-ID: <CAHA+R7ORFYYJTFj4c1Wk34B9gCB92yZK2_q8DDHzmqrSXzRdTw@mail.gmail.com>
References: <3a4673ddb2556634d0cbeae9b31ebc386e720335.1409746289.git.g.nault@alphalink.fr>
	<1409752526.26422.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Guillaume Nault <g.nault@alphalink.fr>,
	Dmitry Petukhov <dmgenp@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:44790 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaIEVra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 17:47:30 -0400
Received: by mail-lb0-f178.google.com with SMTP id v6so14458572lbi.9
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 14:47:28 -0700 (PDT)
In-Reply-To: <1409752526.26422.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 3, 2014 at 6:55 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
> Probably introduced in commit f34c4a35d879 ("l2tp: take PMTU from tunnel
> UDP socket")
>
> CC Dmitry
>
> Before this patch, the bug could not happen.
>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Fixes: f34c4a35d879 ("l2tp: take PMTU from tunnel UDP socket")

Probably it's the time to add "Fixes:" in netdev-FAQ.txt.
