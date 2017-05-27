From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/8] net: extend RTM_GETROUTE to return fib result
Date: Fri, 26 May 2017 23:00:27 -0700
Message-ID: <CAJieiUiK=G1B-LnNH_=MYjFjqQVWu2n15a9Tg5fi_fyvSDpcFQ@mail.gmail.com>
References: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com> <20170526.141838.790479821297151569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Ahern <dsahern@gmail.com>, Rami Rosen <rami.rosen@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:35808 "EHLO
        mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbdE0GA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 02:00:28 -0400
Received: by mail-vk0-f53.google.com with SMTP id h16so13578127vkd.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 23:00:28 -0700 (PDT)
In-Reply-To: <20170526.141838.790479821297151569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 26, 2017 at 11:18 AM, David Miller <davem@davemloft.net> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Thu, 25 May 2017 10:42:32 -0700
>
>> This series adds a new RTM_F_FIB_MATCH flag to return matched fib result
>> with RTM_GETROUTE. This is useful for applications and protocols in
>> userspace wanting to query the selected route.
>
> Looks good, series applied, thanks.
>

thank you.

> Have you considered taking this further and allowing one to see which
> nexthop a route lookup picked?

since the default RTM_GETROUTE output gives most of the attributes
from the resolved dst,
have not considered adding more to it yet...but certainly can if
needed in the future.
