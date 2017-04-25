From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: heap out-of-bounds in
 fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Tue, 25 Apr 2017 10:40:10 -0600
Message-ID: <89026cab-cbc4-4d4d-eaf4-0dd7f10e5c12@cumulusnetworks.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
 <381a3e2d-dbf8-5e26-e6b2-4dc291d49dbe@cumulusnetworks.com>
 <CAAeHK+zVkJ1t1xMhMXO2wUyMfJrbXsARHyQ6A5hh2O9pqPRxiw@mail.gmail.com>
 <CAAeHK+wnFMYUXBCQDBKR142uEVXuGoOvo2SO1b04Ya3i8XSr5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:38893 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1430717AbdDYQkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 12:40:14 -0400
Received: by mail-it0-f43.google.com with SMTP id f187so17432780ite.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 09:40:14 -0700 (PDT)
In-Reply-To: <CAAeHK+wnFMYUXBCQDBKR142uEVXuGoOvo2SO1b04Ya3i8XSr5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/17 10:38 AM, Andrey Konovalov wrote:
> I'll keep fuzzing in the meantime to make sure.
> Maybe I'll be able to collect more reports or even another reproducer.

start a new email thread for each stack trace. I'll write a debug patch
for the trace you hit today.
