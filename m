From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2] PPC: bpf_jit_comp: add SKF_AD_PKTTYPE instruction
Date: Thu, 30 Oct 2014 13:32:44 -0700
Message-ID: <CAADnVQKvfay7zC-kNGXz7uAjVrhqL80xQ=zvmAsSz4pNhD=9NQ@mail.gmail.com>
References: <1414649535-3956-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, Michael Ellerman <mpe@ellerman.id.au>,
	Matt Evans <matt@ozlabs.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:39435 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932513AbaJ3Ucp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 16:32:45 -0400
Received: by mail-qg0-f51.google.com with SMTP id j5so4686550qga.10
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 13:32:45 -0700 (PDT)
In-Reply-To: <1414649535-3956-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2014 at 11:12 PM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> Add BPF extension SKF_AD_PKTTYPE to ppc JIT to load
> skb->pkt_type field.
>
> Before:
> [   88.262622] test_bpf: #11 LD_IND_NET 86 97 99 PASS
> [   88.265740] test_bpf: #12 LD_PKTTYPE 109 107 PASS
>
> After:
> [   80.605964] test_bpf: #11 LD_IND_NET 44 40 39 PASS
> [   80.607370] test_bpf: #12 LD_PKTTYPE 9 9 PASS

if you'd only quoted #12, it would all make sense ;)
but #11 test is not using PKTTYPE. So your patch shouldn't
make a difference. Are these numbers with JIT on and off?
