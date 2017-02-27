From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv6: null-ptr-deref in ip6_route_del/lock_acquire
Date: Mon, 27 Feb 2017 21:37:53 +0100
Message-ID: <CAAeHK+wa_OLcqxrHfsz7gMe1JcQFBE9yO04Uo=B8bvjsqrT3OQ@mail.gmail.com>
References: <CAAeHK+wqCyT6BzgiKLVNbVyoDwOUyDur9Nw-C0HFYjmyAMym9A@mail.gmail.com>
 <CAM_iQpWFnNyk=KfFyDnYOe9iXqgTJWCysx2YMLg19ufbYGdG4g@mail.gmail.com>
 <e260c2c5-26b6-6ef4-563e-b601adc664f9@cumulusnetworks.com>
 <CAAeHK+xTDRBG31crpOZovhisCJx2eMdJacv=dqBsJ0_dd3_tag@mail.gmail.com> <CAM_iQpXjyAAsVSjJfu_c7-eCni7FMNG_MLU_+O6S0yc63JbVVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXjyAAsVSjJfu_c7-eCni7FMNG_MLU_+O6S0yc63JbVVA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2017 at 9:34 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Feb 27, 2017 at 12:05 PM, Andrey Konovalov
> <andreyknvl@google.com> wrote:
>> On Mon, Feb 27, 2017 at 8:59 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>> On 2/27/17 10:11 AM, Cong Wang wrote:
>>>> The attached patch fixes this crash, but I am not sure if it is the
>>>> best way to fix this bug yet...
>>>
>>> I'll take a look. I can not reproduce this using route or ip, so the
>>> fuzzer is doing something interesting.
>>
>> Hi David,
>>
>> I've attached a simple reproducer to the report, it doesn't work for you?
>
> It works for me and I have verified the formal patch I sent.

Hi Cong,

That's what I thought when I read your message, thanks!

I was just confused by David saying that the fuzzer is doing something
interesting, when the reproducer is just an ioctl call on a socket.

>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
