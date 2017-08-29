From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: fdb add and delete tracepoints
Date: Tue, 29 Aug 2017 10:36:50 -0700
Message-ID: <CAJieiUh6D5iUBBq1owL-=Sja9bEYYLOT6P7NTgKZYOMDwyLr_Q@mail.gmail.com>
References: <1503980568-35240-1-git-send-email-roopa@cumulusnetworks.com> <8737eb73-3437-5529-6f4d-7aa52c770357@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        bridge@lists.linux-foundation.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:33549 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbdH2Rgv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 13:36:51 -0400
Received: by mail-ua0-f178.google.com with SMTP id 37so12369547ual.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 10:36:51 -0700 (PDT)
In-Reply-To: <8737eb73-3437-5529-6f4d-7aa52c770357@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 9:46 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 08/28/2017 09:22 PM, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> A few useful tracepoints to trace bridge forwarding
>> database updates.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>
> Small nit below, but probably not a candidate for a v3
>
>> ---
>
>> +
>> +     TP_printk("dev %s addr %02x:%02x:%02x:%02x:%02x:%02x vid %u nlh_flags %04x ndm_flags = %02x",
>
> Small nit, any particular reason why ndm_flags got a special treatment
> with an equal character and not the other?
>


good eyes, thats a typo. I did scan them once and removed the '=' and
missed a spot.
i will send v3.
