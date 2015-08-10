From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [BUG] net/ipv4: inconsistent routing table
Date: Mon, 10 Aug 2015 13:50:06 +0200
Message-ID: <87y4hjgy6p.fsf@stressinduktion.org>
References: <CAOrge3qi=7YPRO+VeCDvHsm_7SFC4Y=+JpwQtwAV3zk_q4fEAw@mail.gmail.com> <55C1D207.3040905@iogearbox.net> <55C24BAE.7090702@gmail.com> <CAOrge3ps456Zw8nnnVitU3t6sEQ=Z=6QzO5Zsp4s17MhhZxyKQ@mail.gmail.com> <55C3B8C8.9030507@redhat.com> <CAOrge3oRWUfdMjDgH8PSY_5Y8=KKv2Cr9T3ZLXvuNx6_eq7g0Q@mail.gmail.com> <55C4D803.3090108@redhat.com> <878u9njaon.fsf@stressinduktion.org> <CAOrge3qxOb_XrspuvYjV0pDDxUUoqGE3690KUQGoxZMxuD-NRQ@mail.gmail.com> <CAOrge3q16PRh3TEBaGUeYDhLzWhCCytn+sopTzBr_23cj1gmaw@mail.gmail.com> <878u9jijuc.fsf@stressinduktion.org> <CAOrge3pSQ7eck14biTncjOyGD-DKY0DvRr7JKpS3BowoSDry-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Zang MingJie <zealot0630@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOrge3pSQ7eck14biTncjOyGD-DKY0DvRr7JKpS3BowoSDry-Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Zang MingJie <zealot0630@gmail.com> writes:

> Here comes several options:
>
> 1. reject local next hop w/ EINVAL
> 2. delete route when local next hop removed

Will also cause some people to complain.

> 3. transition between RT_SCOPE_HOST amd RT_SCOPE_LINK

I don't understand the scope transition. I know Alex mentioned it for
the first time. Maybe he can explain?

> 4. document it

I prefer that one :)

> which one should we choose ?
>
> 1 will definitely cause compatibility problem

Agreed.

> 2 is the easiest solution

Will definietely cause some people to complain.

Bye,
Hannes
