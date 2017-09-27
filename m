From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2] tun: bail out from tun_get_user() if the skb is empty
Date: Wed, 27 Sep 2017 06:26:09 -0700
Message-ID: <CANn89iKL1GzT+9Mnn2OjvPCgmvV4GMhwn5mQzi7yW8_B1wziYA@mail.gmail.com>
References: <20170927121649.90557-1-glider@google.com> <1506516168.6617.38.camel@edumazet-glaptop3.roam.corp.google.com>
 <1506516344.6617.39.camel@edumazet-glaptop3.roam.corp.google.com> <CAG_fn=U8Yjxo2LDC3WenGQUOQZwftd3-j4V8Zz5vSMWobx7Bdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Dmitriy Vyukov <dvyukov@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Networking <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG_fn=U8Yjxo2LDC3WenGQUOQZwftd3-j4V8Zz5vSMWobx7Bdw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 5:58 AM, Alexander Potapenko <glider@google.com> wrote:
> On Wed, Sep 27, 2017 at 2:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Wed, 2017-09-27 at 05:42 -0700, Eric Dumazet wrote:
>>
>>> Or something cleaner to avoid copy/paste and focus on proper
>>> skb->data[0] access and meaning.
> By the way I'm wondering if this is the only place where skb->data is
> being accessed.
> Isn't eth_type_trans() under IFF_TAP also touching it? Then we need to
> check the size earlier.

It is already checked.
