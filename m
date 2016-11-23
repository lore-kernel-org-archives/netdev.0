From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] samples/bpf: fix sockex2 example
Date: Wed, 23 Nov 2016 10:58:28 +0100
Message-ID: <58356844.4030700@iogearbox.net>
References: <1479862329-2361912-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57780 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934181AbcKWJ6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 04:58:31 -0500
In-Reply-To: <1479862329-2361912-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2016 01:52 AM, Alexei Starovoitov wrote:
> since llvm commit "Do not expand UNDEF SDNode during insn selection lowering"
> llvm will generate code that uses uninitialized registers for cases
> where C code is actually uses uninitialized data.
> So this sockex2 example is technically broken.
> Fix it by initializing on the stack variable fully.
> Also increase verifier buffer limit, since verifier output
> may not fit in 64k for this sockex2 code depending on llvm version.
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
