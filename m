From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: Make unnecessarily global functions static
Date: Tue, 10 Jan 2017 16:22:25 -0800
Message-ID: <20170111002222.GA68360@ast-mbp.thefacebook.com>
References: <20170110140216.26550-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Martin KaFai Lau <kafai@fb.com>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36508 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934142AbdAKAWa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 19:22:30 -0500
Received: by mail-pf0-f195.google.com with SMTP id b22so14649678pfd.3
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 16:22:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170110140216.26550-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 03:02:16PM +0100, Tobias Klauser wrote:
> Make the functions __local_list_pop_free(), __local_list_pop_pending(),
> bpf_common_lru_populate() and bpf_percpu_lru_populate() static as they
> are not used outide of bpf_lru_list.c
> 
> This fixes the following GCC warnings when building with 'W=1':
> 
>   kernel/bpf/bpf_lru_list.c:363:22: warning: no previous prototype for ‘__local_list_pop_free’ [-Wmissing-prototypes]
>   kernel/bpf/bpf_lru_list.c:376:22: warning: no previous prototype for ‘__local_list_pop_pending’ [-Wmissing-prototypes]
>   kernel/bpf/bpf_lru_list.c:560:6: warning: no previous prototype for ‘bpf_common_lru_populate’ [-Wmissing-prototypes]
>   kernel/bpf/bpf_lru_list.c:577:6: warning: no previous prototype for ‘bpf_percpu_lru_populate’ [-Wmissing-prototypes]
> 
> Cc: Martin KaFai Lau <kafai@fb.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Acked-by: Alexei Starovoitov <ast@kernel.org>
