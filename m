From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/9] Add BPF_J{LT,LE,SLT,SLE} instructions
Date: Wed, 09 Aug 2017 16:55:40 -0700 (PDT)
Message-ID: <20170809.165540.1340440496413342704.davem@davemloft.net>
References: <cover.1502320623.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752093AbdHIXzm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 19:55:42 -0400
In-Reply-To: <cover.1502320623.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 10 Aug 2017 01:39:54 +0200

> This set adds BPF_J{LT,LE,SLT,SLE} instructions to the BPF
> insn set, interpreter, JIT hardening code and all JITs are
> also updated to support the new instructions. Basic idea is
> to reduce register pressure by avoiding BPF_J{GT,GE,SGT,SGE}
> rewrites. Removing the workaround for the rewrites in LLVM,
> this can result in shorter BPF programs, less stack usage
> and less verification complexity. First patch provides some
> more details on rationale and integration.
> 
> Thanks a lot!
> 
> v1 -> v2:
>   - Reworded commit msg in patch 1

Ok this looks a lot better.

Thanks for taking care of all of the JITs as well.

Series applied.
