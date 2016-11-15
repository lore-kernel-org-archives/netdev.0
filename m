From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: linux-next: BUG: unable to handle kernel NULL pointer
 dereference in __sk_mem_raise_allocated()
Date: Tue, 15 Nov 2016 09:57:19 +0100
Message-ID: <1479200239.4660.3.camel@redhat.com>
References: <CANaxB-yCk8hhP68L4Q2nFOJht8sqgXGGQO2AftpHs0u1xyGG5A@mail.gmail.com>
         <1479166501.8455.91.camel@edumazet-glaptop3.roam.corp.google.com>
         <CANaxB-yYy1vstc-D6GAD=HKjHy68UHQvVukXQSf02MjMvhSxhw@mail.gmail.com>
         <1479169886.8455.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrei Vagin <avagin@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53922 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755456AbcKOI5V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 03:57:21 -0500
In-Reply-To: <1479169886.8455.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-14 at 16:31 -0800, Eric Dumazet wrote:
> On Mon, 2016-11-14 at 15:58 -0800, Andrei Vagin wrote:
> 
> > 
> > Yes, you are right. It works if we set .memory_allocated and .sysctl_mem.
> 
> Now the question would be :
> 
> Are we okay if UDP and UDPlite share the same limits ?
> 
> I would vote for yes, because these default limits are huge anyway
> (The 50% reduction done in
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=b66e91ccbc34ebd5a2f90f9e1bc1597e2924a500
> only impacted TCP )

Thank you for jumping on this so early!

I'm sorry for the udplite left over: my fault.

I agree with sharing the limits between UDP and UDPlite. I think that
the current ones are so high we can apply also a similar reduction to
UDP (and SCTP, too)

Cheers,

Paolo
