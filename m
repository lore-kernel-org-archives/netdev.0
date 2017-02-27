From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net/ipv6: null-ptr-deref in ip6_route_del/lock_acquire
Date: Mon, 27 Feb 2017 11:59:33 -0800
Message-ID: <e260c2c5-26b6-6ef4-563e-b601adc664f9@cumulusnetworks.com>
References: <CAAeHK+wqCyT6BzgiKLVNbVyoDwOUyDur9Nw-C0HFYjmyAMym9A@mail.gmail.com>
 <CAM_iQpWFnNyk=KfFyDnYOe9iXqgTJWCysx2YMLg19ufbYGdG4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
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
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35374 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdB0UHi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 15:07:38 -0500
Received: by mail-pf0-f180.google.com with SMTP id j5so7989185pfb.2
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:07:12 -0800 (PST)
In-Reply-To: <CAM_iQpWFnNyk=KfFyDnYOe9iXqgTJWCysx2YMLg19ufbYGdG4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/27/17 10:11 AM, Cong Wang wrote:
> The attached patch fixes this crash, but I am not sure if it is the
> best way to fix this bug yet...

I'll take a look. I can not reproduce this using route or ip, so the
fuzzer is doing something interesting.
