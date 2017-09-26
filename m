From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 1/2] bpf/verifier: improve disassembly of
 BPF_END instructions
Date: Wed, 27 Sep 2017 00:53:14 +0200
Message-ID: <59CADA5A.1040307@iogearbox.net>
References: <52270348-67f1-4e7a-cd2f-9d611ae94064@solarflare.com> <b0a84ccf-8842-876c-ec82-b4b1da3d6efa@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        ys114321@gmail.com
To: Edward Cree <ecree@solarflare.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41457 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965051AbdIZWxS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 18:53:18 -0400
In-Reply-To: <b0a84ccf-8842-876c-ec82-b4b1da3d6efa@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2017 05:35 PM, Edward Cree wrote:
> print_bpf_insn() was treating all BPF_ALU[64] the same, but BPF_END has a
>   different structure: it has a size in insn->imm (even if it's BPF_X) and
>   uses the BPF_SRC (X or K) to indicate which endianness to use.  So it
>   needs different code to print it.
>
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
