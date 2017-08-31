From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] x86: bpf_jit: small optimization in emit_bpf_tail_call()
Date: Thu, 31 Aug 2017 14:37:28 +0200
Message-ID: <59A80308.307@iogearbox.net>
References: <1504180422.15310.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46778 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbdHaMhd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 08:37:33 -0400
In-Reply-To: <1504180422.15310.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2017 01:53 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Saves 4 bytes replacing following instructions :
>
> lea rax, [rsi + rdx * 8 + offsetof(...)]
> mov rax, qword ptr [rax]
> cmp rax, 0
>
> by :
>
> mov rax, [rsi + rdx * 8 + offsetof(...)]
> test rax, rax
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>

LGTM, thanks Eric!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
