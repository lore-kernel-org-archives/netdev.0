From: Eric Dumazet <edumazet@google.com>
Subject: Re: net: use-after-free in tw_timer_handler
Date: Tue, 24 Jan 2017 07:52:54 -0800
Message-ID: <CANn89iK=5uPEDLpM6=JAKzJ=1GuSSiXw5b_8BrkVUvhYRi_9mw@mail.gmail.com>
References: <CACT4Y+a2t=Ev1-Mp6+aHzRkNPhWaY-dSYRdMeL2Hp7b37bnbUg@mail.gmail.com>
 <CACT4Y+ba65AD9qpjjJqM=_Pn333iWTm86BNmy2A5_EqHTY_kWA@mail.gmail.com>
 <1485268138.16328.297.camel@edumazet-glaptop3.roam.corp.google.com> <CACT4Y+b=-XJCwofbCRo6BnKJRU=amd7pxYpNrGdPEFT0bAtJaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+b=-XJCwofbCRo6BnKJRU=amd7pxYpNrGdPEFT0bAtJaQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2017 at 7:06 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>
>> This code was changed a long time ago :
>>
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ed2e923945892a8372ab70d2f61d364b0b6d9054
>>
>> So I suspect a recent patch broke the logic.
>>
>> You might start a bisection :
>>
>> I would check if 4.7 and 4.8 trigger the issue you noticed.
>
>
> It happens with too low rate for bisecting (few times per day). I
> could add some additional checks into code, but I don't know what
> checks could be useful.

If you can not tell if 4.7 and/or 4.8 have the problem, I am not sure
we are able to help.
