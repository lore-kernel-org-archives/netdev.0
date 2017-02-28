From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: GPF in rt6_nexthop_info
Date: Tue, 28 Feb 2017 15:09:59 -0800
Message-ID: <1a390cbd-1d99-a739-ed94-e0c9d1eecb4a@cumulusnetworks.com>
References: <CACT4Y+b44zwroCAg8QhNZQ5PX-ObhoKQW6VCFC9rt46JijYPYQ@mail.gmail.com>
 <1488287417.9415.237.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, ycheng@google.com,
        Willem de Bruijn <willemb@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488287417.9415.237.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/28/17 5:10 AM, Eric Dumazet wrote:
> David, rt->rt6i_idev can be NULL.

Do you know of an example where rt6i_idev can be NULL - besides the
null_entry rt which is null only because of init order?
