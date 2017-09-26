From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 1/2] bpf/verifier: improve disassembly of
 BPF_END instructions
Date: Tue, 26 Sep 2017 15:33:46 -0700
Message-ID: <20170926223344.3ey6w2qrejrqzqpv@ast-mbp>
References: <52270348-67f1-4e7a-cd2f-9d611ae94064@solarflare.com>
 <b0a84ccf-8842-876c-ec82-b4b1da3d6efa@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        ys114321@gmail.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37845 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031134AbdIZWdt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 18:33:49 -0400
Received: by mail-pf0-f194.google.com with SMTP id e69so5536011pfg.4
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 15:33:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <b0a84ccf-8842-876c-ec82-b4b1da3d6efa@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 04:35:13PM +0100, Edward Cree wrote:
> print_bpf_insn() was treating all BPF_ALU[64] the same, but BPF_END has a
>  different structure: it has a size in insn->imm (even if it's BPF_X) and
>  uses the BPF_SRC (X or K) to indicate which endianness to use.  So it
>  needs different code to print it.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

well, it's an improvement over what we have today, so
Acked-by: Alexei Starovoitov <ast@kernel.org>
