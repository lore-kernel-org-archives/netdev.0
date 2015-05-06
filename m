From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/4] net: filter: add a callback to allow classic
 post-verifier transformations
Date: Wed, 06 May 2015 08:12:36 -0700
Message-ID: <554A2F64.1070202@plumgrid.com>
References: <cover.1430908145.git.daniel@iogearbox.net> <437e17ab5c2cc818d937432cc0397030ee64f916.1430908145.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, nschichan@freebox.fr, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34550 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbbEFPMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 11:12:39 -0400
Received: by pdbqa5 with SMTP id qa5so12468188pdb.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 08:12:39 -0700 (PDT)
In-Reply-To: <437e17ab5c2cc818d937432cc0397030ee64f916.1430908145.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/6/15 7:12 AM, Daniel Borkmann wrote:
> From: Nicolas Schichan <nschichan@freebox.fr>
>
> This is in preparation for use by the seccomp code, the rationale is
> not to duplicate additional code within the seccomp layer, but instead,
> have it abstracted and hidden within the classic BPF API.
>
> As an interim step, this now also makes bpf_prepare_filter() visible
> (not as exported symbol though), so that seccomp can reuse that code
> path instead of reimplementing it.
>
> Joint work with Daniel Borkmann.
>
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Kees Cook <keescook@chromium.org>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
