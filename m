From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Tue, 21 Jun 2016 10:11:30 -0700
Message-ID: <4d1666f1-e52f-c7f6-9b9c-fec38b9ff028@stressinduktion.org>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
 <20160617.200947.2078656051211641868.davem@davemloft.net>
 <CALx6S37GuppbknFiGsGxyP8jAX-t8c1=mWxCToKQVA8r8UPeOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:33091 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751983AbcFURMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 13:12:40 -0400
In-Reply-To: <CALx6S37GuppbknFiGsGxyP8jAX-t8c1=mWxCToKQVA8r8UPeOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.06.2016 20:52, Tom Herbert wrote:
> 
>> > Rather, I think people are going to start adding rules to block TOU
>> > tunnels entirely because they cannot inspect nor conditionally
>> > filter/rewrite the contents.  This is even more likely if Joe Random
>> > and so easily can do their own userland TCP stack over TOU.
>> >
> Unfortunately, encryption is the only proven solution to protocol
> ossification. If the network doesn't see it, it can't ossify it.

DTLS carries still a lot of information, both in its handshake, as well
as in the actual framing. The protocol is basically only TLS on top of
datagrams and as such implements connection establishment and tear down
of connections, which middle boxes can certainly track. It will just be
a matter of time until middle boxes and security appliances will be able
to track those connections, maybe not being able to inspect the content
but at least see the certificates in clear-text and as such also have
the common names and other addressing information at hand. The meta-data
might certainly be track able.

Because of reply protection you actually can infer the number of bytes
transferred and someone can end up building congestion control on a
middle box based on that, infer retransmissions etc.

Bye,
Hannes
