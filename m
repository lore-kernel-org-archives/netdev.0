From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 03/19] netfilter: nf_conntrack_ipv6: improve fragmentation
 handling
Date: Thu, 30 Aug 2012 08:54:07 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208300853120.26781@stinky-local.trash.net>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
 <1346190539-9963-4-git-send-email-kaber@trash.net>
 <Pine.LNX.4.64.1208291007520.32281@ask.diku.dk>
 <Pine.GSO.4.63.1208291424550.26100@stinky-local.trash.net> <20120830030635.GA17583@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120830030635.GA17583@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Aug 2012, Pablo Neira Ayuso wrote:

> On Wed, Aug 29, 2012 at 02:27:00PM +0200, Patrick McHardy wrote:
>>>> +	    (IP6CB(skb)->frag_max_size && IP6CB(skb)->frag_max_size > mtu)) {
>>>
>>> Eric Dumazet would probably nitpick and say, it can be reduced to:
>>> (IP6CB(skb)->frag_max_size > mtu)
>>> ;-)
>>
>> True. I'll fix that once Pablo has pulled in the patches.
>
> If you don't want to wait, you can send me a follow up patch, I'll
> apply it manually.

No hurry, I'll send it with a few other patches once its merged.
