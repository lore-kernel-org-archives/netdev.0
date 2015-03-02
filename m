From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in sch_sfq
Date: Mon, 2 Mar 2015 11:51:46 -0800
Message-ID: <CA+mtBx__JSLgiX9MTa-ErR4kATnCxXbVX+6wQvj8fkh8ZD-mtg@mail.gmail.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
	<1425247789-21211-7-git-send-email-therbert@google.com>
	<1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx-gAq=knRnf73qrOKuWy=WVaHvq2Vzb8RC39p81WBXZ8Q@mail.gmail.com>
	<CA+mtBx-Bhewd6Ez4OotWEhxvVO8rrOieWCGAnMa9vfhTbzj=yg@mail.gmail.com>
	<1425324483.5130.115.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx8sFBV4hFkdnvChuO0UaoN=XHKgVhreM5GwQXXgR9ARvg@mail.gmail.com>
	<1425325397.5130.117.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35303 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948AbbCBTvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:51:47 -0500
Received: by igqa13 with SMTP id a13so20411932igq.0
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 11:51:47 -0800 (PST)
In-Reply-To: <1425325397.5130.117.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 11:43 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2015-03-02 at 11:34 -0800, Tom Herbert wrote:
>
>> Spraying would be quite easy by modulating txhash from TCP and using
>> either  UDP encapsulation like GUE or IPv6 flow labels. Only problem
>> is that this would constantly be changing rxhash at the receiver for
>> the connection, although flow labels might 'just work' with IPv6
>> Toeplitz in NICs.
>
> When I said 'regular IPv4/tcp traffic' this did not include any added
> encapsulation.
>
> Most NIC are not able to properly offload TCP (TSO) with such
> encapsulations.
>
IPv6 flow labels should work through TSO, they would just be
replicated for each segment. You would need switches that can hash
based on flow label though, and of course IPv6 deployed in the network
:-).

>
>
