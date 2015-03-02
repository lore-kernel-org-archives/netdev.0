From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v4 0/2] net: Introducing socket mark receive
 socket option
Date: Mon, 2 Mar 2015 23:11:28 +0200
Message-ID: <CAHsH6Gvh1HwYXqK5mj167ED09R8K5nWMgjSduNOSUVSOcbPuKQ@mail.gmail.com>
References: <20150302143647.GC7418@breakpoint.cc>
	<20150302.150556.807426896557970379.davem@davemloft.net>
	<CAHsH6Gt=WjRb99SrDNo7YLBqXu=p+GsOEFF6O4dhRApfF7fAxw@mail.gmail.com>
	<20150302.155712.103799154284088691.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:45612 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755073AbbCBVL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 16:11:28 -0500
Received: by yhai57 with SMTP id i57so16066916yha.12
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 13:11:28 -0800 (PST)
In-Reply-To: <20150302.155712.103799154284088691.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 10:57 PM, David Miller <davem@davemloft.net> wrote:
> From: Eyal Birger <eyal.birger@gmail.com>
> Date: Mon, 2 Mar 2015 22:38:50 +0200
>
>> I can sum up the motivation for this feature as follows:
>>
>> - skb->mark is set by user-space policy. It would make sense for
>> user-space to be
>>   able to query the resolution of that policy on a per packet basis -
>> even if solely for the
>>   purpose of debugging (e.g. fetching this meta-data on packet sockets
>> on the xmit path
>>   in order to debug tc behavior)
>
> It is also set by routing, netfilter, classifier rules installed by the
> administrator.
>
> Therefore it is not universally true that it is safe to allow applications
> to access this value.
>
> I'm not applying this series, it's use case is at best dubious to me and
> there are security/protection concerns as well.

I understand. Thanks.

Would it be considered if access to the mark value was under CAP_NET_ADMIN
similar to setting SO_MARK?
