From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v3 0/8] xdp: Infrastructure to generalize XDP
Date: Tue, 21 Feb 2017 22:34:57 -0500 (EST)
Message-ID: <20170221.223457.625029624566323414.davem@davemloft.net>
References: <CALx6S358XOdPXjHUNUdnrsK-qmDVkmZXWacy1OPBJudVz31OCw@mail.gmail.com>
        <20170221182341.4b2dd0c8@cakuba.netronome.com>
        <CALx6S36bujuFmDkvG8V5cuigbeNpJX-nprL1_1Ub+m4AiV3Lqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kubakici@wp.pl, netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39474 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752806AbdBVDe7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 22:34:59 -0500
In-Reply-To: <CALx6S36bujuFmDkvG8V5cuigbeNpJX-nprL1_1Ub+m4AiV3Lqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 21 Feb 2017 18:54:53 -0800

> It is part of the direction to take XDP beyond the first use case of
> BPF and leverage the high performance processing model in a much
> broader context.

And I've stated repeatedly that it's too early to be looking
that far into the future.

Look Tom, if all you want to do is create infrastructure so that
you can very easily slither XDP for modules in somewhere, please
just stop now.  Right now I am completely not interested in even
entertaining patches which facilitate that.

If instead, you are genuinely interested in making the process of
writing XDP support for drivers easier, that extremely useful right
now so please just stick to that specific focus.

I really see no other use case for the XDP hook abstraction other
than to support XDP module support, which I've said is in no way
proven to be necessary.

We don't even know what eBPF XDP itself is fully capable of yet,
so please stop reaching like this.

Thank you.
