From: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/7] net: packet: use skb->dev as storage for
 skb orig len instead of skb->cb[]
Date: Sun, 1 Mar 2015 07:35:26 +0200
Message-ID: <CAHsH6Guk_wbXJptkodO+Y5A53UsvrQeeJsM+PXP-3LzA2zUB2Q@mail.gmail.com>
References: <CAHsH6GvvQxHbt4JJrotn3y=BG172Wbw4NrMD+gTUA_R=jbPDTw@mail.gmail.com>
	<20150228.160047.214686672558902639.davem@davemloft.net>
	<CAHsH6Gv8Dh3RQ0V7KURcca9bzZGY0FwiqGj-mP9oKA_Vv72nUA@mail.gmail.com>
	<20150301.003143.1281961486875434872.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Shmulik Ladkani <shmulik.ladkani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150301.003143.1281961486875434872.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 1, 2015 at 7:31 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sun, 1 Mar 2015 07:09:54 +0200
>
>> Ok. Another suggestion I received was to delay the preparation of the full
>> sockaddr_ll until it is needed, and store the skb original length in the first
>> two fields (sll_protocol and sll_family) as they can be derived later on from
>> the skb.
>>
>> IMHO, It would still be somewhat of a hack though.
>>
>> Would that approach be considered?
>
> I think it's better than mangling skb->dev

Ok. Will submit a v3.
