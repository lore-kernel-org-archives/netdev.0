From: Eric Dumazet <edumazet@google.com>
Subject: Re: net: GPF in rt6_nexthop_info
Date: Tue, 28 Feb 2017 15:14:40 -0800
Message-ID: <CANn89iK3qKO6-rr+pNwuk7p--SB9a1sjar00TRN=T_uuh+QZuw@mail.gmail.com>
References: <CACT4Y+b44zwroCAg8QhNZQ5PX-ObhoKQW6VCFC9rt46JijYPYQ@mail.gmail.com>
 <1488287417.9415.237.camel@edumazet-glaptop3.roam.corp.google.com> <1a390cbd-1d99-a739-ed94-e0c9d1eecb4a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Yuchung Cheng <ycheng@google.com>,
        Willem de Bruijn <willemb@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1a390cbd-1d99-a739-ed94-e0c9d1eecb4a@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2017 at 3:09 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 2/28/17 5:10 AM, Eric Dumazet wrote:
>> David, rt->rt6i_idev can be NULL.
>
> Do you know of an example where rt6i_idev can be NULL - besides the
> null_entry rt which is null only because of init order?


I might have been mistaken, but many points in net/ipv6/route.c test
rt->rt6i_idev being NULL or not before dereferencing it.

Maybe other rts (other than null_entry) share this property.
