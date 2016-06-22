From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Tue, 21 Jun 2016 20:42:19 -0700
Message-ID: <CAPshTCgCVs5i1QyLeNPzw2W3X5+r_=5Hw1HOnD+cBsBQBRN35g@mail.gmail.com>
References: <CALx6S37GuppbknFiGsGxyP8jAX-t8c1=mWxCToKQVA8r8UPeOA@mail.gmail.com>
 <20160619.200741.1114304127682357737.davem@davemloft.net> <CALx6S37+o2=Lqzxu_U4QiSvqnq8CjEq5uSpbKVfFfo8r5qD+6g@mail.gmail.com>
 <20160621.042918.1782717212289281861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:35460 "EHLO
	mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbcFVDmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 23:42:21 -0400
Received: by mail-it0-f47.google.com with SMTP id g127so34618475ith.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 20:42:20 -0700 (PDT)
In-Reply-To: <20160621.042918.1782717212289281861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 1:29 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Mon, 20 Jun 2016 08:13:48 -0700
>
>> Routing around the problem is already being done.
>
> QUIC, a new protocol used for specific purposes and implemented in
> userspace from the start is significantly different from making the
> kernel's _TCP_ implementation bypassed into a userspace one just by
> UDP encapsulating it.
>
> That is a major and conscious change in our mentality.
>
> The consequences are far and wide, and I'm having a very hard time
> seeing the benefits you cite being larger than the negatives here.

I don't believe TOU will lead to a proliferation of TCP implementations in
the userland - getting a solid TCP implementation is hard. Yes any smart CS
student in the networking field can write one over a weekend, to get 3WHS
to work, and may even include graceful shutdown. But creating one from
scratch that is both high quality, compliant, highly inter-operable, and highly
performing is really hard. Just look at how much work folks on the list have
to continue to pour in to maintain the Linux TCP stack as the best on the
planet.

Yes TOU may lower the bar for random hacks by Joe Random. But I'd argue
no large organization would serious consider or dare deploy TCP stack
with random hacks. I know we have a very high bar to pass at Google. This
should limit the impact of bad TCP stacks on the Internet. If we continue
to keep up and make timely improvements to the Linux TCP stack, and
better yet, to continue to improve technology like UML and LKL to make it
easy for folks to access great technologies in the Linux kernel stack and
deploy them in the userland, it will probably take away all the motivations
for people to do their own random hacks.

Best,

Jerry
