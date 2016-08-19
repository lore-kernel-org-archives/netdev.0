From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH] samples/bpf: Add tunnel set/get tests.
Date: Fri, 19 Aug 2016 11:56:55 -0700
Message-ID: <CALDO+SY+3pr3_bgXxX9ruixwoNnsidARr2A4Tc5OZb6rQ9Cn3A@mail.gmail.com>
References: <1471356181-32069-1-git-send-email-u9012063@gmail.com> <20160818.211005.1542807415356478774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:33708 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754839AbcHSS5g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 14:57:36 -0400
Received: by mail-it0-f49.google.com with SMTP id f6so6497781ith.0
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 11:57:36 -0700 (PDT)
In-Reply-To: <20160818.211005.1542807415356478774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, I've submitted newer version.

On Thu, Aug 18, 2016 at 9:10 PM, David Miller <davem@davemloft.net> wrote:
> From: William Tu <u9012063@gmail.com>
> Date: Tue, 16 Aug 2016 07:03:01 -0700
>
>> The patch creates sample code exercising bpf_skb_{set,get}_tunnel_key,
>> and bpf_skb_{set,get}_tunnel_opt for GRE, VXLAN, and GENEVE.  A native
>> tunnel device is created in a namespace to interact with a lwtunnel
>> device out of the namespace, with metadata enabled.  The bpf_skb_set_*
>> program is attached to tc egress and bpf_skb_get_* is attached to egress
>> qdisc.  A ping between two tunnels is used to verify correctness and
>> the result of bpf_skb_get_* printed by bpf_trace_printk.
>>
>> Signed-off-by: William Tu <u9012063@gmail.com>
>
> Please respin, this doesn't apply cleanly to net-next.
