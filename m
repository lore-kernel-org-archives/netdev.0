From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH v2] PPC: bpf_jit_comp: add SKF_AD_PKTTYPE instruction
Date: Sat, 1 Nov 2014 20:19:09 +0400
Message-ID: <CAOJe8K31iB9+7c1BnS=6DdriU08WUisM7sYgj8nOBo4Fg=XUBg@mail.gmail.com>
References: <1414649535-3956-1-git-send-email-kda@linux-powerpc.org>
	<CAADnVQKvfay7zC-kNGXz7uAjVrhqL80xQ=zvmAsSz4pNhD=9NQ@mail.gmail.com>
	<CAHj3AVkpouHa1y0jt9c5dyYvnd6dctociTMW1ORdxaKdsFEbhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, Michael Ellerman <mpe@ellerman.id.au>,
	Matt Evans <matt@ozlabs.org>
To: Denis Kirjanov <kirjanov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:36196 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbaKAQTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 12:19:10 -0400
Received: by mail-oi0-f46.google.com with SMTP id g201so7014414oib.33
        for <netdev@vger.kernel.org>; Sat, 01 Nov 2014 09:19:09 -0700 (PDT)
In-Reply-To: <CAHj3AVkpouHa1y0jt9c5dyYvnd6dctociTMW1ORdxaKdsFEbhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping

On 10/31/14, Denis Kirjanov <kirjanov@gmail.com> wrote:
> On 10/30/14, Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>> On Wed, Oct 29, 2014 at 11:12 PM, Denis Kirjanov <kda@linux-powerpc.org>
>> wrote:
>>> Add BPF extension SKF_AD_PKTTYPE to ppc JIT to load
>>> skb->pkt_type field.
>>>
>>> Before:
>>> [   88.262622] test_bpf: #11 LD_IND_NET 86 97 99 PASS
>>> [   88.265740] test_bpf: #12 LD_PKTTYPE 109 107 PASS
>>>
>>> After:
>>> [   80.605964] test_bpf: #11 LD_IND_NET 44 40 39 PASS
>>> [   80.607370] test_bpf: #12 LD_PKTTYPE 9 9 PASS
>>
>> if you'd only quoted #12, it would all make sense ;)
>> but #11 test is not using PKTTYPE. So your patch shouldn't
>> make a difference. Are these numbers with JIT on and off?
>
> Right.
>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
>
> --
> Regards,
> Denis
>
