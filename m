From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Fri, 21 Apr 2017 21:19:37 -0400 (EDT)
Message-ID: <20170421.211937.393214469332032143.davem@davemloft.net>
References: <20170418054444.GA36377@ast-mbp.thefacebook.com>
        <20170418.143732.1494140903085244508.davem@davemloft.net>
        <20170418225707.GA65449@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.net
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41138 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425547AbdDVBTj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 21:19:39 -0400
In-Reply-To: <20170418225707.GA65449@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 18 Apr 2017 15:57:09 -0700

> Alternative idea: can the above
> 'add FP, STACK_BIAS, one_of_local_regs' be done once in prologue
> and that register used as substitue for R10 ?

After much consideration I think this is what I'm going to end up
doing, I should have listened to you from the beginning :-)

It will simplify the JIT significantly.

Now I will just have to completely trust that the verifier has audited
all the FP accesses properly. :-)
