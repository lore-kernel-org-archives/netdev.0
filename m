From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2 0/8] net: extend RTM_GETROUTE to return fib
 result
Date: Sat, 27 May 2017 08:02:40 -0600
Message-ID: <8d6cf942-6d24-2cbc-bf5b-650d570927bb@gmail.com>
References: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
 <20170526.141838.790479821297151569.davem@davemloft.net>
 <CAJieiUiK=G1B-LnNH_=MYjFjqQVWu2n15a9Tg5fi_fyvSDpcFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rami Rosen <rami.rosen@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35772 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756711AbdE0OCt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 10:02:49 -0400
Received: by mail-pg0-f67.google.com with SMTP id i63so1615690pgd.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 07:02:49 -0700 (PDT)
In-Reply-To: <CAJieiUiK=G1B-LnNH_=MYjFjqQVWu2n15a9Tg5fi_fyvSDpcFQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/27/17 12:00 AM, Roopa Prabhu wrote:
> On Fri, May 26, 2017 at 11:18 AM, David Miller <davem@davemloft.net> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Date: Thu, 25 May 2017 10:42:32 -0700
>>
>>> This series adds a new RTM_F_FIB_MATCH flag to return matched fib result
>>> with RTM_GETROUTE. This is useful for applications and protocols in
>>> userspace wanting to query the selected route.
>>
>> Looks good, series applied, thanks.
>>
> 
> thank you.
> 
>> Have you considered taking this further and allowing one to see which
>> nexthop a route lookup picked?
> 
> since the default RTM_GETROUTE output gives most of the attributes
> from the resolved dst,
> have not considered adding more to it yet...but certainly can if
> needed in the future.
> 

One extension is to pass in prefix and length (plus any options to such
as metric to uniquely discriminate a route) and get back the route
entry. It is needed to retrieve the BPF code for routes with a bpf
encap. This patch set makes it easier.
