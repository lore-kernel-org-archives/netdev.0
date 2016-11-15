From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: Fix compilation warning in
 __bpf_lru_list_rotate_inactive
Date: Tue, 15 Nov 2016 13:44:30 -0800
Message-ID: <20161115214428.GA19854@ast-mbp.thefacebook.com>
References: <1479236404-3906780-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34433 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752308AbcKOVof (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 16:44:35 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so12405253pgc.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 13:44:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1479236404-3906780-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 11:00:04AM -0800, Martin KaFai Lau wrote:
> gcc-6.2.1 gives the following warning:
> kernel/bpf/bpf_lru_list.c: In function ‘__bpf_lru_list_rotate_inactive.isra.3’:
> kernel/bpf/bpf_lru_list.c:201:28: warning: ‘next’ may be used uninitialized in this function [-Wmaybe-uninitialized]
> 
> The "next" is currently initialized in the while() loop which must have >=1
> iterations.
> 
> This patch initializes next to get rid of the compiler warning.
> 
> Fixes: 3a08c2fd7634 ("bpf: LRU List")
> Reported-by: David Miller <davem@davemloft.net>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
