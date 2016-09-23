From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Fri, 23 Sep 2016 07:13:30 -0400
Message-ID: <06280af8-5451-c423-d295-a5f3f51e63cf@mojatatu.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, tariqt@mellanox.com, bblanco@plumgrid.com,
        alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
        brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33949 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759149AbcIWLNc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 07:13:32 -0400
Received: by mail-io0-f193.google.com with SMTP id y139so6950303ioy.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 04:13:32 -0700 (PDT)
In-Reply-To: <1474408824-418864-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-20 06:00 PM, Tom Herbert wrote:
> This patch creates an infrastructure for registering and running code at
> XDP hooks in drivers. This is based on the orignal XDP?BPF and borrows
> heavily from the techniques used by netfilter to make generic nfhooks.
>
> An XDP hook is defined by the  xdp_hook_ops. This structure contains the
> ops of an XDP hook. A pointer to this structure is passed into the XDP
> register function to set up a hook. The XDP register function mallocs
> its own xdp_hook_ops structure and copies the values from the
> xdp_hook_ops passed in. The register function also stores the pointer
> value of the xdp_hook_ops argument; this pointer is used in subsequently
> calls to XDP to identify the registered hook.
>
> The interface is defined in net/xdp.h. This includes the definition of
> xdp_hook_ops, functions to register and unregister hook ops on a device
> or individual instances of napi, and xdp_hook_run that is called by
> drivers to run the hooks.
>

Tom,
perused the thread and it seems you are serious ;->
Are we heading towards Frankenstein Avenue?
The whole point behind letting in XDP is so that _small programs_
can be written to do some quick thing. eBPF 4K program limit was
touted as the check and bound. eBPF sounded fine.
This sounds like a huge contradiction.

cheers,
jamal
