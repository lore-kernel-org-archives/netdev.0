From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net/ipv6: null-ptr-deref in ip6_route_del/lock_acquire
Date: Mon, 27 Feb 2017 13:02:30 -0800
Message-ID: <26caf164-171b-ebfb-5f5a-3b2bca836c69@cumulusnetworks.com>
References: <CAAeHK+wqCyT6BzgiKLVNbVyoDwOUyDur9Nw-C0HFYjmyAMym9A@mail.gmail.com>
 <CAM_iQpWFnNyk=KfFyDnYOe9iXqgTJWCysx2YMLg19ufbYGdG4g@mail.gmail.com>
 <e260c2c5-26b6-6ef4-563e-b601adc664f9@cumulusnetworks.com>
 <CAAeHK+xTDRBG31crpOZovhisCJx2eMdJacv=dqBsJ0_dd3_tag@mail.gmail.com>
 <CAM_iQpXjyAAsVSjJfu_c7-eCni7FMNG_MLU_+O6S0yc63JbVVA@mail.gmail.com>
 <CAAeHK+wa_OLcqxrHfsz7gMe1JcQFBE9yO04Uo=B8bvjsqrT3OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
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
To: Andrey Konovalov <andreyknvl@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34790 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751748AbdB0V3Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 16:29:16 -0500
Received: by mail-pg0-f49.google.com with SMTP id p5so24915330pga.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 13:27:32 -0800 (PST)
In-Reply-To: <CAAeHK+wa_OLcqxrHfsz7gMe1JcQFBE9yO04Uo=B8bvjsqrT3OQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/27/17 12:37 PM, Andrey Konovalov wrote:
> That's what I thought when I read your message, thanks!
> 
> I was just confused by David saying that the fuzzer is doing something
> interesting, when the reproducer is just an ioctl call on a socket.

It means I have a cold, recently off a plane and not processing what I
was reading.

The interesting part was intent to delete the null route, but then Cong
mentioned that in his commit message.
