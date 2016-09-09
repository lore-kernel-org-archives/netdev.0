From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC Patch net-next 5/6] net_sched: use rcu in fast path
Date: Fri, 9 Sep 2016 08:25:36 -0700
Message-ID: <57D2D470.2050806@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
 <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D0FF87.604@gmail.com>
 <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D18894.2070702@gmail.com>
 <CAM_iQpXJFwtEwWLbL6umapCY-_pkNy0xTyjvkbXQVFJGFWaOcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36646 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753490AbcIIPZt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 11:25:49 -0400
Received: by mail-pa0-f45.google.com with SMTP id id6so29353192pad.3
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 08:25:49 -0700 (PDT)
In-Reply-To: <CAM_iQpXJFwtEwWLbL6umapCY-_pkNy0xTyjvkbXQVFJGFWaOcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-08 10:54 PM, Cong Wang wrote:
> On Thu, Sep 8, 2016 at 8:49 AM, John Fastabend <john.fastabend@gmail.com> wrote:
>> Agreed not sure why you would ever want to do a late binding and
>> replace on a tc_mirred actions. But it is supported...
> 
> I will let Jamal teach you on this, /me is really tired of explaining
> things to you John.
> 

This was a meta-comment on the use case for doing this with mirred
action. Not necessarily about the patch itself.

I was actually curious where this happens in practice. The only thing
I can think of is your external logging box moved so you need to send
out another port. Is there any open source software that manages 'tc'
like this. If so I would like to read it.

So do you know of any?

.John
