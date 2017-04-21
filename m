From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v6 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 09:10:23 -0700
Message-ID: <1492791023.6453.29.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
         <1492772132-16559-3-git-send-email-jhs@emojatatu.com>
         <20170421131220.GC1874@nanopsycho.orion>
         <1dea2c80-9c86-353e-6a74-f5b86070df04@mojatatu.com>
         <1492788031.6453.14.camel@edumazet-glaptop3.roam.corp.google.com>
         <6b26ef20-972f-24bf-22bf-8462606ce16d@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34798 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1041384AbdDUQjh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 12:39:37 -0400
Received: by mail-io0-f193.google.com with SMTP id h41so32140421ioi.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 09:39:37 -0700 (PDT)
In-Reply-To: <6b26ef20-972f-24bf-22bf-8462606ce16d@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-21 at 11:40 -0400, Jamal Hadi Salim wrote:
> On 17-04-21 11:20 AM, Eric Dumazet wrote:
> > On Fri, 2017-04-21 at 11:12 -0400, Jamal Hadi Salim wrote:
> >> On 17-04-21 09:12 AM, Jiri Pirko wrote:
> >>> Fri, Apr 21, 2017 at 12:55:31PM CEST, jhs@mojatatu.com wrote:
> >>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
> >>
> 
> >> Jiri, there is a balance between extensibility and performance.
> >> It is senseless to use a TLV just so i can set a 0/1(true/false).
> >
> > You assume that the (user space) did sensible things.
> >
> 
> If it didnt it is a bug. Seriously.


If the application runs fine on linux-4.0, it is our _duty_ [1] to allow
it to run on linux-4.12.

Particularly if we have very easy ways to do so.

Like using new attributes instead of trying to 'reuse' some padding.

Pretending the old compiler or old applications were buggy is absolutely
irrelevant. That is not the point.

[1] Ask Linus Torvalds about that if you really need to get a final
arbitration.
