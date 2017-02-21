From: Tom Herbert <tom@herbertland.com>
Subject: Re: Focusing the XDP project
Date: Tue, 21 Feb 2017 10:23:57 -0800
Message-ID: <CALx6S34HarCtNp8EwTQaw+pqT2O4hgydnC3f8bhaD6RrOphJ3g@mail.gmail.com>
References: <CALx6S375878KeM0O7BO9sB7B_3p+yO4yxfEhxYdn_=AZvWF-Aw@mail.gmail.com>
 <20170221.114617.1686255511436946338.davem@davemloft.net> <CALx6S36qPxUgvmp4taQFd0OzWyQ9Z4Rv8t+cnph_MAQHiGkvCw@mail.gmail.com>
 <20170221.131100.165451416977377136.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        john fastabend <john.fastabend@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:35425 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753897AbdBUSX7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:23:59 -0500
Received: by mail-qt0-f172.google.com with SMTP id x35so44907808qtc.2
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 10:23:58 -0800 (PST)
In-Reply-To: <20170221.131100.165451416977377136.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 10:11 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Tue, 21 Feb 2017 09:40:17 -0800
>
>> I'd be more supportive of this line of thinking if we (e.g. FB) didn't
>> have to spend the majority time over the past few months trying to
>> deal with all the complexity being thrown into drivers for all these
>> new features such as XDP. Case in point, Mellanox drivers are
>> completely non-modular and have a horrible directory structure. They
>> tried to fix, this but the patch set was rejected because it would
>> break people trying to do backports. That's a fair argument, but the
>> lesson I gather from that is that we should put more time in up front
>> thinking about how to structure code the right way instead of just
>> throwing it in and trying to deal with the consequences later.
>
> Hey aren't you guys suffering from this because you're stuck on an
> older kernel for one reason or another?  Don't we constantly give
> the Android guys a hard time about this? ;-)

Ha, isn't "everyone is stuck on an older kernel for one reason or
another" a metaphor for life? ;-) Backports/rebases/maintainence/bug
fixing/testing are the unglamorous realities of kernel engineers
trying to deploy in production!
