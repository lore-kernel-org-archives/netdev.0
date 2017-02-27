From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: null-ptr-deref in ip6_route_del/lock_acquire
Date: Mon, 27 Feb 2017 12:34:10 -0800
Message-ID: <CAM_iQpXjyAAsVSjJfu_c7-eCni7FMNG_MLU_+O6S0yc63JbVVA@mail.gmail.com>
References: <CAAeHK+wqCyT6BzgiKLVNbVyoDwOUyDur9Nw-C0HFYjmyAMym9A@mail.gmail.com>
 <CAM_iQpWFnNyk=KfFyDnYOe9iXqgTJWCysx2YMLg19ufbYGdG4g@mail.gmail.com>
 <e260c2c5-26b6-6ef4-563e-b601adc664f9@cumulusnetworks.com> <CAAeHK+xTDRBG31crpOZovhisCJx2eMdJacv=dqBsJ0_dd3_tag@mail.gmail.com>
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
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+xTDRBG31crpOZovhisCJx2eMdJacv=dqBsJ0_dd3_tag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2017 at 12:05 PM, Andrey Konovalov
<andreyknvl@google.com> wrote:
> On Mon, Feb 27, 2017 at 8:59 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> On 2/27/17 10:11 AM, Cong Wang wrote:
>>> The attached patch fixes this crash, but I am not sure if it is the
>>> best way to fix this bug yet...
>>
>> I'll take a look. I can not reproduce this using route or ip, so the
>> fuzzer is doing something interesting.
>
> Hi David,
>
> I've attached a simple reproducer to the report, it doesn't work for you?

It works for me and I have verified the formal patch I sent.
