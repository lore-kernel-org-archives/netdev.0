From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/4] seccomp: simplify seccomp_prepare_filter
 and reuse bpf_prepare_filter
Date: Wed, 06 May 2015 08:15:18 -0700
Message-ID: <554A3006.6010003@plumgrid.com>
References: <cover.1430908145.git.daniel@iogearbox.net> <7c2f7da437c992f239d7e3883983dc25500b77b2.1430908145.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, nschichan@freebox.fr, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36820 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbbEFPPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 11:15:21 -0400
Received: by pdea3 with SMTP id a3so12463736pde.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 08:15:20 -0700 (PDT)
In-Reply-To: <7c2f7da437c992f239d7e3883983dc25500b77b2.1430908145.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/6/15 7:12 AM, Daniel Borkmann wrote:
> From: Nicolas Schichan <nschichan@freebox.fr>
>
> Remove the calls to bpf_check_classic(), bpf_convert_filter() and
> bpf_migrate_runtime() and let bpf_prepare_filter() take care of that
> instead.
>
> seccomp_check_filter() is passed to bpf_prepare_filter() so that it
> gets called from there, after bpf_check_classic().
>
> We can now remove exposure of two internal classic BPF functions
> previously used by seccomp. The export of bpf_check_classic() symbol,
> previously known as sk_chk_filter(), was there since pre git times,
> and no in-tree module was using it, therefore remove it.
>
> Joint work with Daniel Borkmann.
>
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Kees Cook <keescook@chromium.org>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
