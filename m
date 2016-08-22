From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCHv2,net-next] samples/bpf: Add tunnel set/get tests.
Date: Mon, 22 Aug 2016 09:13:40 -0700
Message-ID: <CALDO+Sb=Ou-pMtfNmeJemK86tLdrAr2FQ+zuBRHHRRz=TP2pTg@mail.gmail.com>
References: <1471632944-2315-1-git-send-email-u9012063@gmail.com> <20160819.224321.216830178281905910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:35794 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754953AbcHVQOV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 12:14:21 -0400
Received: by mail-it0-f47.google.com with SMTP id x131so94377985ite.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 09:14:21 -0700 (PDT)
In-Reply-To: <20160819.224321.216830178281905910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. I will do it next time.

On Fri, Aug 19, 2016 at 10:43 PM, David Miller <davem@davemloft.net> wrote:
> From: William Tu <u9012063@gmail.com>
> Date: Fri, 19 Aug 2016 11:55:44 -0700
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
> Applied, thanks.
>
> Next time, propagate the ACK's your received into your commit message
> when you post new versions.
