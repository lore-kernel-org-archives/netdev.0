From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/2] net: Introducing socket mark receive
 socket option
Date: Mon, 02 Mar 2015 23:01:44 -0500 (EST)
Message-ID: <20150302.230144.1866086388165440495.davem@davemloft.net>
References: <CAHsH6Gvh1HwYXqK5mj167ED09R8K5nWMgjSduNOSUVSOcbPuKQ@mail.gmail.com>
	<20150302.164520.1544544356329556012.davem@davemloft.net>
	<CAHsH6Gvs+xroJrKR9GH3xHQAt1QzThejPNqX+6tkSsd4mvbgkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, willemb@google.com, edumazet@google.com,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org
To: eyal.birger@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56501 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbbCCEBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 23:01:46 -0500
In-Reply-To: <CAHsH6Gvs+xroJrKR9GH3xHQAt1QzThejPNqX+6tkSsd4mvbgkg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Birger <eyal.birger@gmail.com>
Date: Tue, 3 Mar 2015 05:45:39 +0200

>>>> I'm not applying this series, it's use case is at best dubious to me and
>>>> there are security/protection concerns as well.
>>>
>>> I understand. Thanks.
>>>
>>> Would it be considered if access to the mark value was under CAP_NET_ADMIN
>>> similar to setting SO_MARK?
>>
>> I said there are two issues blocking it's inclusion, so dealing with only
>> one of those is insufficient, right?
> 
> Right. Thanks.
> 
> In that case I suggest reverting 744d5a3e9fe2690
> ("net: move skb->dropcount to skb->cb[]") as it has no justification without
> this feature and wastes 4 bytes of skb->cb[] space.

It may allow us to make other simplifications to sk_buff so I'm
keeping it in.
