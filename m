From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 2/2] bpf/verifier: improve disassembly of
 BPF_NEG instructions
Date: Wed, 27 Sep 2017 00:53:32 +0200
Message-ID: <59CADA6C.1000300@iogearbox.net>
References: <52270348-67f1-4e7a-cd2f-9d611ae94064@solarflare.com> <f27b1dfe-4ea2-5737-d3d5-21cb581d1927@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        ys114321@gmail.com
To: Edward Cree <ecree@solarflare.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41489 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969634AbdIZWxf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 18:53:35 -0400
In-Reply-To: <f27b1dfe-4ea2-5737-d3d5-21cb581d1927@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2017 05:35 PM, Edward Cree wrote:
> BPF_NEG takes only one operand, unlike the bulk of BPF_ALU[64] which are
>   compound-assignments.  So give it its own format in print_bpf_insn().
>
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
