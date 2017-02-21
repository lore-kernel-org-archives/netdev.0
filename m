From: David Miller <davem@davemloft.net>
Subject: Re: Focusing the XDP project
Date: Tue, 21 Feb 2017 11:46:17 -0500 (EST)
Message-ID: <20170221.114617.1686255511436946338.davem@davemloft.net>
References: <CAKgT0Ucqp6+jWkiGxDoEE-UdbnxsdVLxjZZ6uYtNWHSo4fPUVg@mail.gmail.com>
        <cc26e1ce-05ae-6c3d-a323-b6f18e2ad897@mellanox.com>
        <CALx6S375878KeM0O7BO9sB7B_3p+yO4yxfEhxYdn_=AZvWF-Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, alexander.duyck@gmail.com, brouer@redhat.com,
        alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        netdev@vger.kernel.org, bblanco@gmail.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54776 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752935AbdBUQqV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 11:46:21 -0500
In-Reply-To: <CALx6S375878KeM0O7BO9sB7B_3p+yO4yxfEhxYdn_=AZvWF-Aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 21 Feb 2017 08:35:41 -0800

> We already have good APIs for similar datapath functionality (GRO,
> GSO, xmit_more, etc.), and I don't see why XDP is so special that we
> can't come up with a reasonable API for batching and implement it.

What you are missing is that it wasn't always this way.

The initial TSO support was a hodge-podge of weird driver APIs and
simple heuristics thrown all over the place.  It was ugly but worked
and allowed us to experiment.  We had to adjust driver internals
a lot until on the way towards getting things how they are today.

This is the natural course of things, so please don't suggest that XDP
shouldn't evolve in the same way.

I think we really need to be fast and loose right now and only try to
constrict and perfect the API after some of this initial activity has
died down.

Yes it's more work for the brave drivers that add XDP support, but
unfortunately that's how we figure out what's really needed and works
in the long term.
