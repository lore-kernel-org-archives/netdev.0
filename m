From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] bpf: devmap fix arithmetic overflow in bitmap_size
 calculation
Date: Sun, 22 Oct 2017 00:54:41 +0100 (WEST)
Message-ID: <20171022.005441.760530707225820143.davem@davemloft.net>
References: <150842903200.12537.10765604428561566031.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard@nod.at, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org, borkmann@iogearbox.net
To: john.r.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56366 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932254AbdJUXyr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 19:54:47 -0400
In-Reply-To: <150842903200.12537.10765604428561566031.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@gmail.com>
Date: Thu, 19 Oct 2017 09:03:52 -0700

> An integer overflow is possible in dev_map_bitmap_size() when
> calculating the BITS_TO_LONG logic which becomes, after macro
> replacement,
> 
> 	(((n) + (d) - 1)/ (d))
> 
> where 'n' is a __u32 and 'd' is (8 * sizeof(long)). To avoid
> overflow cast to u64 before arithmetic.
> 
> Reported-by: Richard Weinberger <richard@nod.at>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Applied.
