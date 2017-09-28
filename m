From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] bpf/verifier: disassembly improvements
Date: Thu, 28 Sep 2017 10:24:53 -0700 (PDT)
Message-ID: <20170928.102453.506974154025585871.davem@davemloft.net>
References: <52270348-67f1-4e7a-cd2f-9d611ae94064@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, ys114321@gmail.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751339AbdI1RYy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:24:54 -0400
In-Reply-To: <52270348-67f1-4e7a-cd2f-9d611ae94064@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 26 Sep 2017 16:32:15 +0100

> Fix the output of print_bpf_insn() for ALU ops that don't look like
>  compound assignment (i.e. BPF_END and BPF_NEG).
> 
> Sample output for a short test program:
> 0: (b4) (u32) r0 = (u32) 0
> 1: (dc) r0 = be32 r0
> 2: (84) r0 = (u32) -r0
> 3: (95) exit
> processed 4 insns, stack depth 0

Series applied.
