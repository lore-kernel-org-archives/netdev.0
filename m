From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Mon, 11 Jul 2005 21:02:59 -0700 (PDT)
Message-ID: <20050711.210259.77057135.davem@davemloft.net>
References: <20050708.003014.125896217.davem@davemloft.net>
	<42CE3722.3070208@cosmosbay.com>
	<39e6f6c7050708040877702f6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: arnaldo.melo@gmail.com
In-Reply-To: <39e6f6c7050708040877702f6f@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Date: Fri, 8 Jul 2005 08:08:54 -0300

> > struct inet_sock {
> > /* sk and pinet6 has to be the first two members of inet_sock */
> > struct sock sk;
> > #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> > struct ipv6_pinfo *pinet6;
> > #endif
> 
> /me pleads guilty, Dave, any problem with removing this #ifdef? Humm, I'll 
> think about using

Just leave it for now.  If we come up with some spectacularly
nice way to deal with this in the future, we can change it then.
