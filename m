From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 4/4] seccomp, filter: add and use bpf_prog_create_from_user
 from seccomp
Date: Wed, 06 May 2015 08:21:17 -0700
Message-ID: <554A316D.6070305@plumgrid.com>
References: <cover.1430908145.git.daniel@iogearbox.net> <1ff9bc3432f272308ae6bb8945994df3f8ceadbb.1430908146.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, nschichan@freebox.fr, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33912 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbbEFPVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 11:21:20 -0400
Received: by pdbqa5 with SMTP id qa5so12686168pdb.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 08:21:19 -0700 (PDT)
In-Reply-To: <1ff9bc3432f272308ae6bb8945994df3f8ceadbb.1430908146.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/6/15 7:12 AM, Daniel Borkmann wrote:
> Seccomp has always been a special candidate when it comes to preparation
> of its filters in seccomp_prepare_filter(). Due to the extra checks and
> filter rewrite it partially duplicates code and has BPF internals exposed.
>
> This patch adds a generic API inside the BPF code code that seccomp can use
> and thus keep it's filter preparation code minimal and better maintainable.
> The other side-effect is that now classic JITs can add seccomp support as
> well by only providing a BPF_LDX | BPF_W | BPF_ABS translation.
>
> Tested with seccomp and BPF test suites.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Nicolas Schichan <nschichan@freebox.fr>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Kees Cook <keescook@chromium.org>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
