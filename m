From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv6: null-ptr-deref in ip6_route_del/lock_acquire
Date: Mon, 27 Feb 2017 21:05:54 +0100
Message-ID: <CAAeHK+xTDRBG31crpOZovhisCJx2eMdJacv=dqBsJ0_dd3_tag@mail.gmail.com>
References: <CAAeHK+wqCyT6BzgiKLVNbVyoDwOUyDur9Nw-C0HFYjmyAMym9A@mail.gmail.com>
 <CAM_iQpWFnNyk=KfFyDnYOe9iXqgTJWCysx2YMLg19ufbYGdG4g@mail.gmail.com> <e260c2c5-26b6-6ef4-563e-b601adc664f9@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
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
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e260c2c5-26b6-6ef4-563e-b601adc664f9@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2017 at 8:59 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 2/27/17 10:11 AM, Cong Wang wrote:
>> The attached patch fixes this crash, but I am not sure if it is the
>> best way to fix this bug yet...
>
> I'll take a look. I can not reproduce this using route or ip, so the
> fuzzer is doing something interesting.

Hi David,

I've attached a simple reproducer to the report, it doesn't work for you?

Thanks!
