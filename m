From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] net: filter: add __GFP_NOWARN flag for larger
 kmem allocs
Date: Wed, 06 May 2015 08:16:51 -0700
Message-ID: <554A3063.3030003@plumgrid.com>
References: <cover.1430908145.git.daniel@iogearbox.net> <0ea8655bc24a1ea3da6da66adcb2410aebc55db6.1430908146.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, nschichan@freebox.fr, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:36852 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbbEFPQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 11:16:53 -0400
Received: by pdea3 with SMTP id a3so12502634pde.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 08:16:53 -0700 (PDT)
In-Reply-To: <0ea8655bc24a1ea3da6da66adcb2410aebc55db6.1430908146.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/6/15 7:12 AM, Daniel Borkmann wrote:
> When seccomp BPF was added, it was discussed to add __GFP_NOWARN
> flag for their configuration path as f.e. up to 32K allocations are
> more prone to fail under stress. As we're going to reuse BPF API,
> add __GFP_NOWARN flags where larger kmalloc() and friends allocations
> could fail.
>
> It doesn't make much sense to pass around __GFP_NOWARN everywhere as
> an extra argument only for seccomp while we just as well could run
> into similar issues for socket filters, where it's not desired to
> have a user application throw a WARN() due to allocation failure.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Nicolas Schichan <nschichan@freebox.fr>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Kees Cook <keescook@chromium.org>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
