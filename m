From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 binutils] Add BPF support to binutils...
Date: Mon, 01 May 2017 23:51:58 -0400 (EDT)
Message-ID: <20170501.235158.89801140704756675.davem@davemloft.net>
References: <20170430.120750.651845251226226775.davem@davemloft.net>
        <33505cff-f730-ebac-c2d7-38f1793062b7@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750847AbdEBDwA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 23:52:00 -0400
In-Reply-To: <33505cff-f730-ebac-c2d7-38f1793062b7@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 1 May 2017 20:49:21 -0700

> (gdb) x/10i bpf_prog1
>    0x0 <bpf_prog1>:	ldimm64	r0, 590618314553
>    0x10 <bpf_prog1+16>:	stdw	[r1+-8], r10
>    0x18 <bpf_prog1+24>:	lddw	r10, [r1+-8]
>    0x20 <bpf_prog1+32>:	add	r0, -1879113726
>    0x28 <bpf_prog1+40>:	lddw	r1, [r0+0]
>    0x30 <bpf_prog1+48>:	exit
>    0x38:	Cannot access memory at address 0x38
> 
> the last line also seems wrong. Off by 1 error?

Maybe, I'll look into it tomorrow.  I'll also post my fix for the
branch destination disassembler output tomorrow as well.
