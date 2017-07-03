From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] Misc BPF helper/verifier improvements
Date: Mon, 03 Jul 2017 02:23:19 -0700 (PDT)
Message-ID: <20170703.022319.786875746405217541.davem@davemloft.net>
References: <cover.1498952486.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54700 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753259AbdGCJXW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 05:23:22 -0400
In-Reply-To: <cover.1498952486.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun,  2 Jul 2017 02:13:24 +0200

> Miscellanous improvements I still had in my queue, it adds a new
> bpf_skb_adjust_room() helper for cls_bpf, exports to fdinfo whether
> tail call array owner is JITed, so iproute2 error reporting can be
> improved on that regard, a small cleanup and extension to trace
> printk, two verifier patches, one to make the code around narrower
> ctx access a bit more straight forward and one to allow for imm += x
> operations, that we've seen LLVM generating and the verifier currently
> rejecting. We've included the patch 6 given it's rather small and
> we ran into it from LLVM side, it would be great if it could be
> queued for stable as well after the merge window. Last but not least,
> test cases are added also related to imm alu improvement.

Series applied, thanks Daniel.
