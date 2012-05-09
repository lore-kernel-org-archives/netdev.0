From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netfilter: remove two dropwatch false positives
Date: Wed, 09 May 2012 15:00:40 +0200
Message-ID: <1336568440.21775.17.camel@edumazet-laptop>
References: <1335942790.22133.55.camel@edumazet-glaptop>
	 <20120509113647.GA23243@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120509113647.GA23243@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 09 mai 2012 =C3=A0 13:36 +0200, Pablo Neira Ayuso a =C3=A9c=
rit :
> On Wed, May 02, 2012 at 09:13:10AM +0200, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >=20
> > After skb_copy_expand() call, we want to switch skbs without droppi=
ng
> > original one. Call consume_skb() to avoid drop_monitor sending a dr=
op
> > event.
>=20
> We have removed ip_queue in 3.5. That's why I cannot take this patch.

So far, so good !

Thanks


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
