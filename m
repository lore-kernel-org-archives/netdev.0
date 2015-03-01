From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/7] net: packet: use skb->dev as storage
 for skb orig len instead of skb->cb[]
Date: Sun, 01 Mar 2015 00:31:43 -0500 (EST)
Message-ID: <20150301.003143.1281961486875434872.davem@davemloft.net>
References: <CAHsH6GvvQxHbt4JJrotn3y=BG172Wbw4NrMD+gTUA_R=jbPDTw@mail.gmail.com>
	<20150228.160047.214686672558902639.davem@davemloft.net>
	<CAHsH6Gv8Dh3RQ0V7KURcca9bzZGY0FwiqGj-mP9oKA_Vv72nUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, shmulik.ladkani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHsH6Gv8Dh3RQ0V7KURcca9bzZGY0FwiqGj-mP9oKA_Vv72nUA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Sun, 1 Mar 2015 07:09:54 +0200

> Ok. Another suggestion I received was to delay the preparation of the full
> sockaddr_ll until it is needed, and store the skb original length in the first
> two fields (sll_protocol and sll_family) as they can be derived later on from
> the skb.
> 
> IMHO, It would still be somewhat of a hack though.
> 
> Would that approach be considered?

I think it's better than mangling skb->dev
