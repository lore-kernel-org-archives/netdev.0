From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] bpf/verifier: improve disassembly of
 BPF_NEG instructions
Date: Tue, 26 Sep 2017 15:34:16 -0700
Message-ID: <20170926223414.hdyveon53ev5dqi2@ast-mbp>
References: <52270348-67f1-4e7a-cd2f-9d611ae94064@solarflare.com>
 <f27b1dfe-4ea2-5737-d3d5-21cb581d1927@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        ys114321@gmail.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:49744 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032596AbdIZWeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 18:34:19 -0400
Received: by mail-pg0-f54.google.com with SMTP id m30so6682448pgn.6
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 15:34:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <f27b1dfe-4ea2-5737-d3d5-21cb581d1927@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 04:35:29PM +0100, Edward Cree wrote:
> BPF_NEG takes only one operand, unlike the bulk of BPF_ALU[64] which are
>  compound-assignments.  So give it its own format in print_bpf_insn().
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>

thank you for the cleanup.
