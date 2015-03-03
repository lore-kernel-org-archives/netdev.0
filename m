From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v4 0/2] net: Introducing socket mark receive
 socket option
Date: Tue, 3 Mar 2015 05:45:39 +0200
Message-ID: <CAHsH6Gvs+xroJrKR9GH3xHQAt1QzThejPNqX+6tkSsd4mvbgkg@mail.gmail.com>
References: <CAHsH6Gt=WjRb99SrDNo7YLBqXu=p+GsOEFF6O4dhRApfF7fAxw@mail.gmail.com>
	<20150302.155712.103799154284088691.davem@davemloft.net>
	<CAHsH6Gvh1HwYXqK5mj167ED09R8K5nWMgjSduNOSUVSOcbPuKQ@mail.gmail.com>
	<20150302.164520.1544544356329556012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:43687 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753950AbbCCDpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 22:45:39 -0500
Received: by yhab6 with SMTP id b6so16941682yha.10
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 19:45:39 -0800 (PST)
In-Reply-To: <20150302.164520.1544544356329556012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> I'm not applying this series, it's use case is at best dubious to me and
>>> there are security/protection concerns as well.
>>
>> I understand. Thanks.
>>
>> Would it be considered if access to the mark value was under CAP_NET_ADMIN
>> similar to setting SO_MARK?
>
> I said there are two issues blocking it's inclusion, so dealing with only
> one of those is insufficient, right?

Right. Thanks.

In that case I suggest reverting 744d5a3e9fe2690
("net: move skb->dropcount to skb->cb[]") as it has no justification without
this feature and wastes 4 bytes of skb->cb[] space.
