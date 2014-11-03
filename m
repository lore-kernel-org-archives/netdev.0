From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] PPC: bpf_jit_comp: add SKF_AD_PKTTYPE instruction
Date: Mon, 03 Nov 2014 15:29:58 -0500 (EST)
Message-ID: <20141103.152958.2144581734281584875.davem@davemloft.net>
References: <1414649535-3956-1-git-send-email-kda@linux-powerpc.org>
	<20141103.120633.183870310578884991.davem@davemloft.net>
	<CAADnVQJYNB15cQvDi0+AcL==n+f8PAb1=Dnp_vBWku4SA-Q_6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felix@linux.vnet.ibm.com, kda@linux-powerpc.org,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	mpe@ellerman.id.au, matt@ozlabs.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49191 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458AbaKCUaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 15:30:04 -0500
In-Reply-To: <CAADnVQJYNB15cQvDi0+AcL==n+f8PAb1=Dnp_vBWku4SA-Q_6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Mon, 3 Nov 2014 09:21:03 -0800

> On Mon, Nov 3, 2014 at 9:06 AM, David Miller <davem@davemloft.net> wrote:
>> From: Denis Kirjanov <kda@linux-powerpc.org>
>> Date: Thu, 30 Oct 2014 09:12:15 +0300
>>
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
>>>
>>> CC: Alexei Starovoitov<alexei.starovoitov@gmail.com>
>>> CC: Michael Ellerman<mpe@ellerman.id.au>
>>> Cc: Matt Evans <matt@ozlabs.org>
>>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>>>
>>> v2: Added test rusults
>>
>> So, can I apply this now?
> 
> I think this question is more towards ppc folks,
> since both Daniel and myself said before that it looks ok.
> Philippe just tested the previous version of this patch on ppc64le...
> I'm guessing that Matt (original author of bpf jit for ppc) is not replying,
> because he has no objections.
> Either way the addition is tiny and contained, so can go in now.

Ok, I have applied this to net-next, thanks everyone.
