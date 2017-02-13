From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: reduce compiler warnings by adding fallthrough comments
Date: Tue, 14 Feb 2017 00:18:05 +0100
Message-ID: <58A23EAD.6040800@iogearbox.net>
References: <20170213230235.12677-1-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: ast@kernel.org, brouer@redhat.com, dcb314@hotmail.com,
        jbacik@fb.com
To: Alexander Alemayhu <alexander@alemayhu.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35112 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751250AbdBMXSI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 18:18:08 -0500
In-Reply-To: <20170213230235.12677-1-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2017 12:02 AM, Alexander Alemayhu wrote:
> Fixes the following warnings:
>
> kernel/bpf/verifier.c: In function ‘may_access_direct_pkt_data’:
> kernel/bpf/verifier.c:702:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
>     if (t == BPF_WRITE)
>        ^
> kernel/bpf/verifier.c:704:2: note: here
>    case BPF_PROG_TYPE_SCHED_CLS:
>    ^~~~
> kernel/bpf/verifier.c: In function ‘reg_set_min_max_inv’:
> kernel/bpf/verifier.c:2057:23: warning: this statement may fall through [-Wimplicit-fallthrough=]
>     true_reg->min_value = 0;
>     ~~~~~~~~~~~~~~~~~~~~^~~
> kernel/bpf/verifier.c:2058:2: note: here
>    case BPF_JSGT:
>    ^~~~
> kernel/bpf/verifier.c:2068:23: warning: this statement may fall through [-Wimplicit-fallthrough=]
>     true_reg->min_value = 0;
>     ~~~~~~~~~~~~~~~~~~~~^~~
> kernel/bpf/verifier.c:2069:2: note: here
>    case BPF_JSGE:
>    ^~~~
> kernel/bpf/verifier.c: In function ‘reg_set_min_max’:
> kernel/bpf/verifier.c:2009:24: warning: this statement may fall through [-Wimplicit-fallthrough=]
>     false_reg->min_value = 0;
>     ~~~~~~~~~~~~~~~~~~~~~^~~
> kernel/bpf/verifier.c:2010:2: note: here
>    case BPF_JSGT:
>    ^~~~
> kernel/bpf/verifier.c:2019:24: warning: this statement may fall through [-Wimplicit-fallthrough=]
>     false_reg->min_value = 0;
>     ~~~~~~~~~~~~~~~~~~~~~^~~
> kernel/bpf/verifier.c:2020:2: note: here
>    case BPF_JSGE:
>    ^~~~
>
> Reported-by: David Binderman <dcb314@hotmail.com>
> Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>

These fall-through comments are fine for net-next tree.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
