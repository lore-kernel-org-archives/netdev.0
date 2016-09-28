From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 08:38:26 -0400
Message-ID: <df4fcadf-2442-7ad9-ca38-769842f7a7cb@mojatatu.com>
References: <20160928112703.GW1876@uranus.lan>
 <20160928.080701.1194277590163223525.davem@davemloft.net>
 <60b2e075-e852-f0c2-c188-631f547791d5@mojatatu.com>
 <20160928.081646.1634500099795129398.davem@davemloft.net>
 <70b51ac5-a7d1-8b52-90c4-7f80ec8ad4d5@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, eric.dumazet@gmail.com,
        dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33830 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932273AbcI1Mi3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:38:29 -0400
Received: by mail-io0-f193.google.com with SMTP id g22so696836ioj.1
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:38:28 -0700 (PDT)
In-Reply-To: <70b51ac5-a7d1-8b52-90c4-7f80ec8ad4d5@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-28 08:27 AM, Jamal Hadi Salim wrote:
> On 16-09-28 08:16 AM, David Miller wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>> Date: Wed, 28 Sep 2016 08:09:28 -0400
>>
>>> On 16-09-28 08:07 AM, David Miller wrote:
>>>
>>>> Right, it would be legal for an existing user to have code that
>>>> explicitly initializes every member of the structure, including 'pad'.
>>>> So we have to keep that member around, at a minimum, for their sake.
>>>>
>>>
>>> I think we need to start labelling any new pad fields added as
>>> "Not UAPI. Do not fsck fondle this".
>>
>> They must initialize it to zero.
>>
>
> What if in the future actually meant to use 0 for
> something?;-> For example in Cyrill's case it means PROTO_IP
> Not sure if it useful to interpret or not but it is part of the
> enum for protocols.

I just tested with: socket(AF_INET, SOCK_RAW, 0);

and got back: EPROTONOSUPPORT

So in this case doesnt matter. But my point stands i.e 0 could mean
something.

cheers,
jamal
