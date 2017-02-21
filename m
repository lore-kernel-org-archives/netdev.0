From: David Miller <davem@davemloft.net>
Subject: Re: Focusing the XDP project
Date: Tue, 21 Feb 2017 13:11:00 -0500 (EST)
Message-ID: <20170221.131100.165451416977377136.davem@davemloft.net>
References: <CALx6S375878KeM0O7BO9sB7B_3p+yO4yxfEhxYdn_=AZvWF-Aw@mail.gmail.com>
        <20170221.114617.1686255511436946338.davem@davemloft.net>
        <CALx6S36qPxUgvmp4taQFd0OzWyQ9Z4Rv8t+cnph_MAQHiGkvCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, alexander.duyck@gmail.com, brouer@redhat.com,
        alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        netdev@vger.kernel.org, bblanco@gmail.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55858 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752751AbdBUSLH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:11:07 -0500
In-Reply-To: <CALx6S36qPxUgvmp4taQFd0OzWyQ9Z4Rv8t+cnph_MAQHiGkvCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 21 Feb 2017 09:40:17 -0800

> I'd be more supportive of this line of thinking if we (e.g. FB) didn't
> have to spend the majority time over the past few months trying to
> deal with all the complexity being thrown into drivers for all these
> new features such as XDP. Case in point, Mellanox drivers are
> completely non-modular and have a horrible directory structure. They
> tried to fix, this but the patch set was rejected because it would
> break people trying to do backports. That's a fair argument, but the
> lesson I gather from that is that we should put more time in up front
> thinking about how to structure code the right way instead of just
> throwing it in and trying to deal with the consequences later.

Hey aren't you guys suffering from this because you're stuck on an
older kernel for one reason or another?  Don't we constantly give
the Android guys a hard time about this? ;-)
