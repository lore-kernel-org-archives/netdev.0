From: Denis Kirjanov <kirjanov@gmail.com>
Subject: Re: [PATCH v2] PPC: bpf_jit_comp: add SKF_AD_PKTTYPE instruction
Date: Fri, 31 Oct 2014 10:09:43 +0400
Message-ID: <CAHj3AVkpouHa1y0jt9c5dyYvnd6dctociTMW1ORdxaKdsFEbhQ@mail.gmail.com>
References: <1414649535-3956-1-git-send-email-kda@linux-powerpc.org>
	<CAADnVQKvfay7zC-kNGXz7uAjVrhqL80xQ=zvmAsSz4pNhD=9NQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Denis Kirjanov <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, Michael Ellerman <mpe@ellerman.id.au>,
	Matt Evans <matt@ozlabs.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:37438 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758785AbaJaGJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 02:09:44 -0400
Received: by mail-vc0-f180.google.com with SMTP id hy10so3522144vcb.11
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 23:09:43 -0700 (PDT)
In-Reply-To: <CAADnVQKvfay7zC-kNGXz7uAjVrhqL80xQ=zvmAsSz4pNhD=9NQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/14, Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> On Wed, Oct 29, 2014 at 11:12 PM, Denis Kirjanov <kda@linux-powerpc.org>
> wrote:
>> Add BPF extension SKF_AD_PKTTYPE to ppc JIT to load
>> skb->pkt_type field.
>>
>> Before:
>> [   88.262622] test_bpf: #11 LD_IND_NET 86 97 99 PASS
>> [   88.265740] test_bpf: #12 LD_PKTTYPE 109 107 PASS
>>
>> After:
>> [   80.605964] test_bpf: #11 LD_IND_NET 44 40 39 PASS
>> [   80.607370] test_bpf: #12 LD_PKTTYPE 9 9 PASS
>
> if you'd only quoted #12, it would all make sense ;)
> but #11 test is not using PKTTYPE. So your patch shouldn't
> make a difference. Are these numbers with JIT on and off?

Right.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Regards,
Denis
