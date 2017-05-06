From: David Miller <davem@davemloft.net>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Sat, 06 May 2017 14:38:16 -0400 (EDT)
Message-ID: <20170506.143816.2259768618578706384.davem@davemloft.net>
References: <CAHgaXdJ1M4W3p9=B2hJmtxByPsA5-XHae8U6YtDH_2r_XMaR5A@mail.gmail.com>
        <58E639E0.1010700@iogearbox.net>
        <CAHgaXdK1XjDnhTqtk=nCq2crrigHiuCaLhF+1GupJt9bPThwZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, keescook@chromium.org, mgherzan@gmail.com,
        netdev@vger.kernel.org, kernel-hardening@lists.openwall.com,
        linux-arm-kernel@lists.infradead.org, ast@fb.com
To: illusionist.neo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750721AbdEFSiY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 14:38:24 -0400
In-Reply-To: <CAHgaXdK1XjDnhTqtk=nCq2crrigHiuCaLhF+1GupJt9bPThwZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shubham Bansal <illusionist.neo@gmail.com>
Date: Sat, 6 May 2017 22:18:16 +0530

> Hi Daniel,
> 
> Thanks for the last reply about the testing of eBPF JIT.
> 
> I have one issue though, I am not able to find what BPF_ABS and
> BPF_IND instruction does exactly.

They are not instructions, they are modifiers for the BPF_LD
instruction which indicate an SKB load is to be performed.

You never need to ask what a BPF instruction does, it is clear
defined in the BPF interperter found in kernel/bpf/core.c

Look for the case statement LD_ABS_W and friends in __bpf_prog_run().
