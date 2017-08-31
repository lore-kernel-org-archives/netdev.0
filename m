From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] x86: bpf_jit: small optimization in
 emit_bpf_tail_call()
Date: Thu, 31 Aug 2017 11:58:14 -0700 (PDT)
Message-ID: <20170831.115814.350681783104301165.davem@davemloft.net>
References: <1504180422.15310.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55974 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751639AbdHaS6P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 14:58:15 -0400
In-Reply-To: <1504180422.15310.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 31 Aug 2017 04:53:42 -0700

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

Applied.
