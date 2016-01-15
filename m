From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] netfilter: xt_TCPMSS: handle CHECKSUM_COMPLETE in
 tcpmss_tg6()
Date: Fri, 15 Jan 2016 09:18:44 -0800
Message-ID: <1452878324.1223.188.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452874892.1223.175.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S348Td5ZHVDTOn+DudAjs9pNjhs6kkEbn-CgYCqXEh0BQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CALx6S348Td5ZHVDTOn+DudAjs9pNjhs6kkEbn-CgYCqXEh0BQg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-01-15 at 08:43 -0800, Tom Herbert wrote:

> Probably should have a utility function do this. Maybe something like
> update_hdr_field(skb, old, new)? Could return new value so above could
> just be:
> 
> ipv6h->payload_len = update_hdr_field(skb, ipv6h->payload_len,
> htons(ntohs(oldlen) + ret);

Well, oldlen would still need to be ipv6h->payload_len

Not sure a helper will be nice for a stable submission.

Probably better for net-next ?


