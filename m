From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/2] net: Introducing socket mark receive
 socket option
Date: Mon, 02 Mar 2015 16:45:20 -0500 (EST)
Message-ID: <20150302.164520.1544544356329556012.davem@davemloft.net>
References: <CAHsH6Gt=WjRb99SrDNo7YLBqXu=p+GsOEFF6O4dhRApfF7fAxw@mail.gmail.com>
	<20150302.155712.103799154284088691.davem@davemloft.net>
	<CAHsH6Gvh1HwYXqK5mj167ED09R8K5nWMgjSduNOSUVSOcbPuKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, willemb@google.com, edumazet@google.com,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org
To: eyal.birger@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372AbbCBVpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 16:45:24 -0500
In-Reply-To: <CAHsH6Gvh1HwYXqK5mj167ED09R8K5nWMgjSduNOSUVSOcbPuKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Birger <eyal.birger@gmail.com>
Date: Mon, 2 Mar 2015 23:11:28 +0200

> On Mon, Mar 2, 2015 at 10:57 PM, David Miller <davem@davemloft.net> wrote:
>> From: Eyal Birger <eyal.birger@gmail.com>
>> Date: Mon, 2 Mar 2015 22:38:50 +0200
>>
>>> I can sum up the motivation for this feature as follows:
>>>
>>> - skb->mark is set by user-space policy. It would make sense for
>>> user-space to be
>>>   able to query the resolution of that policy on a per packet basis -
>>> even if solely for the
>>>   purpose of debugging (e.g. fetching this meta-data on packet sockets
>>> on the xmit path
>>>   in order to debug tc behavior)
>>
>> It is also set by routing, netfilter, classifier rules installed by the
>> administrator.
>>
>> Therefore it is not universally true that it is safe to allow applications
>> to access this value.
>>
>> I'm not applying this series, it's use case is at best dubious to me and
>> there are security/protection concerns as well.
> 
> I understand. Thanks.
> 
> Would it be considered if access to the mark value was under CAP_NET_ADMIN
> similar to setting SO_MARK?

I said there are two issues blocking it's inclusion, so dealing with only
one of those is insufficient, right?
