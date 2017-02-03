From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next] bpf: enable verifier to add 0 to packet ptr
Date: Fri, 03 Feb 2017 21:39:44 +0100
Message-ID: <5894EA90.4090807@iogearbox.net>
References: <1486142565-2794-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mihai Budiu <mbudiu@vmware.com>,
        ast@kernel.org
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33840 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752359AbdBCUjq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 15:39:46 -0500
In-Reply-To: <1486142565-2794-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ please keep us Cc'ed ;) ]

On 02/03/2017 06:22 PM, William Tu wrote:
> The patch fixes the case when adding a zero value to the packet
> pointer.  The verifer reports the following error:
>    [...]
>      R0=imm0,min_value=0,max_value=0
>      R1=pkt(id=0,off=0,r=4)
>      R2=pkt_end R3=fp-12
>      R4=imm4,min_value=4,max_value=4
>      R5=pkt(id=0,off=4,r=4)
>    269: (bf) r2 = r0	// r2 becomes imm0
>    270: (77) r2 >>= 3
>    271: (bf) r4 = r1	// r4 becomes pkt ptr
>    272: (0f) r4 += r2	// r4 += 0
>    addition of negative constant to packet pointer is not allowed
>
> Signed-off-by: William Tu <u9012063@gmail.com>
> Signed-off-by: Mihai Budiu <mbudiu@vmware.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks!
