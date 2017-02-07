From: David Miller <davem@davemloft.net>
Subject: Re: [PATHv3 net-next] bpf: enable verifier to add 0 to packet ptr
Date: Mon, 06 Feb 2017 22:50:15 -0500 (EST)
Message-ID: <20170206.225015.897322994264531777.davem@davemloft.net>
References: <1486226249-1851-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mbudiu@vmware.com, daniel@iogearbox.net,
        ast@kernel.org
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56900 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBGDuR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 22:50:17 -0500
In-Reply-To: <1486226249-1851-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Sat,  4 Feb 2017 08:37:29 -0800

> The patch fixes the case when adding a zero value to the packet
> pointer.  The zero value could come from src_reg equals type
> BPF_K or CONST_IMM.  The patch fixes both, otherwise the verifer
> reports the following error:
>   [...]
>     R0=imm0,min_value=0,max_value=0
>     R1=pkt(id=0,off=0,r=4)
>     R2=pkt_end R3=fp-12
>     R4=imm4,min_value=4,max_value=4
>     R5=pkt(id=0,off=4,r=4)
>   269: (bf) r2 = r0     // r2 becomes imm0
>   270: (77) r2 >>= 3
>   271: (bf) r4 = r1     // r4 becomes pkt ptr
>   272: (0f) r4 += r2    // r4 += 0
>   addition of negative constant to packet pointer is not allowed
> 
> Signed-off-by: William Tu <u9012063@gmail.com>
> Signed-off-by: Mihai Budiu <mbudiu@vmware.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
