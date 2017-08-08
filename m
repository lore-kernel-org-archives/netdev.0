From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v3 net-next 3/5] sock: ULP infrastructure
Date: Tue, 8 Aug 2017 10:07:28 -0700
Message-ID: <CALx6S35WZeZS_+tOxEcShvBdyJnEY2E_7NeKqf_tC_eghRp7cg@mail.gmail.com>
References: <20170807172818.31855-1-tom@quantonium.net> <20170807172818.31855-4-tom@quantonium.net>
 <87shh2t3od.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>,
        Dave Watson <davejwatson@fb.com>,
        john fastabend <john.fastabend@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33717 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752059AbdHHRHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 13:07:30 -0400
Received: by mail-wr0-f196.google.com with SMTP id y43so2857722wrd.0
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 10:07:29 -0700 (PDT)
In-Reply-To: <87shh2t3od.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 8, 2017 at 9:38 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Tom Herbert <tom@quantonium.net> writes:
>
>> +#ifdef CONFIG_MODULES
>> +     if (!ulp && capable(CAP_NET_ADMIN)) {
>> +             rcu_read_unlock();
>> +             request_module("%s", name);
>> +             rcu_read_lock();
>> +             ulp = ulp_find(name);
>> +     }
>> +#endif
>
> It looks to me that this allows users with only CAP_NET_ADMIN
> privileges to load every module?

It's a carryover. Probably should remove the check.

Tom
