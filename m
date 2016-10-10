From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net] net_sched: do not broadcast RTM_GETTFILTER result
Date: Mon, 10 Oct 2016 09:16:05 -0400
Message-ID: <ea0ddd16-5c81-a0af-1a2a-4c1b5fe1bb35@mojatatu.com>
References: <1476069955.28155.292.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34849 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752218AbcJJNQI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 09:16:08 -0400
Received: by mail-io0-f193.google.com with SMTP id p26so7349865ioo.2
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 06:16:07 -0700 (PDT)
In-Reply-To: <1476069955.28155.292.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-09 11:25 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> There are two ways to get tc filters from kernel to user space.
>
> 1) Full dump (tc_dump_tfilter())
> 2) RTM_GETTFILTER to get one precise filter, reducing overhead.
>
> The second operation is unfortunately broadcasting its result,
> polluting "tc monitor" users.
>
> This patch makes sure only the requester gets the result, using
> netlink_unicast() instead of rtnetlink_send()
>
> Jamal cooked an iproute2 patch to implement "tc filter get" operation,
> but other user space libraries already use RTM_GETTFILTER when a single
> filter is queried, instead of dumping all filters.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

I will send the iproute2 patch

cheers,
jamal
