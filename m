From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] bpf: stack depth tracking
Date: Wed, 31 May 2017 19:30:04 -0400 (EDT)
Message-ID: <20170531.193004.888451467604231918.davem@davemloft.net>
References: <20170530203135.3642768-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46100 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbdEaXaG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 19:30:06 -0400
In-Reply-To: <20170530203135.3642768-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 30 May 2017 13:31:26 -0700

> Introduce tracking of bpf program stack depth in the verifier and use that
> info to reduce bpf program stack consumption in the interpreter and x64 JIT.
> Other JITs can take advantage of it as well in the future.
> Most of the programs consume very little stack, so it's good optimization
> in general and it's the first step toward bpf to bpf function calls.
> 
> Also use internal opcode for bpf_tail_call() marking to make clear
> that jmp|call|x opcode is not uapi and may be used for actual
> indirect call opcode in the future.

Series applied, thanks Alexei.
