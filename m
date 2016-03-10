From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 13:09:15 -0800
Message-ID: <CAM_iQpU3EuioDavDQAXMuuyRAXPQn2O+hOmnwcWMawrusNiX4g@mail.gmail.com>
References: <20160310150920.GC21154@uranus.lan>
	<20160310.130138.1302349043066531127.davem@davemloft.net>
	<CAM_iQpWWbj00H-cKvpeaKq6mVWK_D2CFuarXiE6YDQeQX5JupA@mail.gmail.com>
	<20160310.145543.990436948715023108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cyrill Gorcunov <gorcunov@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	solar@openwall.com, Vasily Averin <vvs@virtuozzo.com>,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160310.145543.990436948715023108.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2016 at 11:55 AM, David Miller <davem@davemloft.net> wrote:
> Indeed, good catch.  Therefore:
>
> 1) Keep the masq netdev notifier.  That will flush the conntrack table
>    for the inetdev_destroy event.
>
> 2) Make the inetdev notifier only do something if inetdev->dead is
>    false.  (ie. we are flushing an individual address)
>
> And then we don't need the NETDEV_UNREGISTER thing at all:


This makes sense to me. I guess similar thing needs to do for IPv6 masq too.

Thanks.
