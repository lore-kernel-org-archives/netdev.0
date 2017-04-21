From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Fri, 21 Apr 2017 12:46:40 -0400 (EDT)
Message-ID: <20170421.124640.1134810340055330244.davem@davemloft.net>
References: <20170416.233825.1748421481008153466.davem@davemloft.net>
        <58F50D13.3090001@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35124 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162126AbdDURCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 13:02:36 -0400
In-Reply-To: <58F50D13.3090001@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 17 Apr 2017 20:44:35 +0200

> There is samples/bpf/sockex3_kern.c, which exercises it. To
> run it, it would be (clang/llvm needed due to BPF backend not
> available in gcc):
> 
> # cd samples/bpf
> # make
> # ./sockex3
> IP     src.port -> dst.port               bytes      packets
> 127.0.0.1.12865 -> 127.0.0.1.49711          148            2
> 127.0.0.1.49711 -> 127.0.0.1.12865          108            2
> [...]
> 
> Inside parse_eth_proto(), it will do tail calls based on the
> eth protocol. Over time, we'll move such C based tests over to
> tools/testing/selftests/bpf/.

Ok, after a lot of work setting up an LLVM/CLANG environment and other
things, I implemented tail call support and got this working.

Thanks for the pointers.
