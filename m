From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Tue, 09 May 2017 16:51:48 -0700
Message-ID: <1494373908.7796.100.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
         <20170508.143557.105629611489969352.davem@davemloft.net>
         <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170508.212211.1291611254198273979.davem@davemloft.net>
         <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com>
         <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
         <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com>
         <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
         <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34338 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750927AbdEIXvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 19:51:51 -0400
Received: by mail-pf0-f182.google.com with SMTP id e64so7275211pfd.1
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 16:51:51 -0700 (PDT)
In-Reply-To: <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-09 at 16:35 -0700, Cong Wang wrote:

> This statement is only used to ensure we pass the "dead == fi->fib_nhs"
> check right below the inner loop, it is fine to keep it without break since
> fi is not changed in the inner loop.
> 

So the dead++ above wont end up with (dead > fi->fib_nhs) ?
