From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v6] net: ip, diag -- Add diag interface for raw sockets
Date: Thu, 13 Oct 2016 09:43:57 -0600
Message-ID: <e59c339f-ca3d-92e9-88e0-8c3e9e02e01a@cumulusnetworks.com>
References: <20161006100055.GA1941@uranus.lan>
 <20161012.015022.2273537782016406180.davem@davemloft.net>
 <20161012065329.GH1941@uranus.lan>
 <20161012.195504.658773172040030000.davem@davemloft.net>
 <20161013071648.GA1946@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jhs@mojatatu.com,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34491 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752771AbcJMPoK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 11:44:10 -0400
Received: by mail-pa0-f54.google.com with SMTP id rz1so39683780pab.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 08:44:00 -0700 (PDT)
In-Reply-To: <20161013071648.GA1946@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/16 1:16 AM, Cyrill Gorcunov wrote:
> On Wed, Oct 12, 2016 at 07:55:04PM -0400, David Miller wrote:
>> From: Cyrill Gorcunov <gorcunov@gmail.com>
>> Date: Wed, 12 Oct 2016 09:53:29 +0300
>>
>>> I can't rename the field, neither a can use union.
>>
>> Remind me again what is wrong with using an anonymous union?
> 
> Anon union would be a preferred but Eric pointed me that even
> though it might cause problems (https://patchwork.kernel.org/patch/9353365/)
> 
>  | Note that some programs could fail to compile with the added union
>  | anyway.
>  |
>  | Some gcc versions are unable to compile a static init with an union
>  |
>  | struct inet_diag_req_v2 foo = { .pad = 0, sdiag_family = AF_INET, };
>  |
>  | When I cooked my recent fq commit I simply removed a pad and replaced
>  | it :
>  |
>  | git show fefa569a9d4bc4 -- include
> 

That commit suggests it is acceptable to just rename the pad field, which is the simplest approach.
