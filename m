From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 3/5] bpf: Add BPF_SOCKET_OPS_BASE_RTT support to
 tcp_nv
Date: Sat, 21 Oct 2017 12:37:17 -0700
Message-ID: <20171021193715.5cdwmeuseklqnkyc@ast-mbp>
References: <20171020180543.4156833-1-brakmo@fb.com>
 <20171020180543.4156833-4-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Blake Matheny <bmatheny@fb.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:44224 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932159AbdJUThV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 15:37:21 -0400
Received: by mail-pg0-f45.google.com with SMTP id j3so8970745pga.1
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2017 12:37:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171020180543.4156833-4-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 11:05:41AM -0700, Lawrence Brakmo wrote:
> TCP_NV will try to get the base RTT from a socket_ops BPF program if one
> is loaded. NV will then use the base RTT to bound its min RTT (its
> notion of the base RTT). It uses the base RTT as an upper bound and 80%
> of the base RTT as its lower bound.
...
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
> Acked_by: Alexei Starovoitov <ast@fb.com>
       ^
just noticed the typo above :)
fixing it with:
Acked-by: Alexei Starovoitov <ast@kernel.org>

so patchworks can pick it up automatically.
