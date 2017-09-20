From: Xiang Gao <qasdfgtyuiop@gmail.com>
Subject: Re: [PATCH] ipv6_skip_exthdr: use ipv6_authlen for AH hdrlen
Date: Wed, 20 Sep 2017 12:17:31 -0400
Message-ID: <CAMtaSwQ4Czd6_Hwx3urTvYrY5=J1Z3czEzvZocw2YauoHd2sdw@mail.gmail.com>
References: <20170919125950.11537-1-qasdfgtyuiop@gmail.com> <20170919.153208.1575676406897804623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: trivial@kernel.org, netdev@vger.kernel.org,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:52559 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdITQRw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 12:17:52 -0400
Received: by mail-it0-f52.google.com with SMTP id c195so3603002itb.1
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 09:17:52 -0700 (PDT)
In-Reply-To: <20170919.153208.1575676406897804623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Thanks for your time and all your suggestions. I will resend a new patch soon.

Xiang Gao
Xiang Gao


2017-09-19 18:32 GMT-04:00 David Miller <davem@davemloft.net>:
> From: Xiang Gao <qasdfgtyuiop@gmail.com>
> Date: Tue, 19 Sep 2017 08:59:50 -0400
>
>> In ipv6_skip_exthdr, the lengh of AH header is computed manually
>> as (hp->hdrlen+2)<<2. However, in include/linux/ipv6.h, a macro
>> named ipv6_authlen is already defined for exactly the same job. This
>> commit replaces the manual computation code with the macro.
>
> All patch submissions must have a proper signoff.
>
> Also, please use a proper subsystem prefix in your Subject
> line "[PATCH] ipv6: Use ipv6_authlen for AH hdrlen in ipv6_skip_exthdr()"
> would have been much better as "ipv6: " is the appropriate
> subsystem prefix to use here.
>
> Thanks.
