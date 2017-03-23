From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [net-next PATCH v2 0/8] Add busy poll support for epoll
Date: Thu, 23 Mar 2017 15:49:08 -0700
Message-ID: <CANn89i+ygBw_tHcAaDJhHJqvOYAqkHJ3nnokByUQWVeXv0MDfA@mail.gmail.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
 <20170323220721.GA62356@ast-mbp.thefacebook.com> <CAKgT0Uctdf4N-w72EY8T5Zfw=QCSCgAesXdgOh-HUYdD=Aq9AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Samudrala, Sridhar" <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgT0Uctdf4N-w72EY8T5Zfw=QCSCgAesXdgOh-HUYdD=Aq9AA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 23, 2017 at 3:38 PM, Alexander Duyck
<alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Thu, Mar 23, 2017 at 3:07 PM, Alexei Starovoitov

>> it all sounds awesome, but i cannot quite visualize the impact.
>> Can you post some sample code/minibenchmark and numbers before/after?
>>
>> Thanks!
>>
>
> Anything specific you are looking for?  I can probably work with our
> team internally to setup the benchmark in the next day or so.
>
> I've been doing most of my benchmarking at my desk with sockperf with
> just one thread and multiple sockets and seeing some modest savings
> with my round trip times dropping from something like 18 microseconds
> on average to 8 microseconds for ping-pong tests.

Same reduction for me, on 1000/1000 bytes RPC.

26 usec -> 16 usec  per transaction

(If you use sockperf, beware that it displays half round trips)

Also note that the gains also depends on how the interrupt mitigation
parameters are set.
