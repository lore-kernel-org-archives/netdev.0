From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/3] samples/bpf: add -Wno-unknown-warning-option
 to clang
Date: Mon, 24 Apr 2017 16:37:41 +0200
Message-ID: <58FE0DB5.20802@iogearbox.net>
References: <20170424133108.31595-1-alexander@alemayhu.com> <20170424133108.31595-2-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com
To: Alexander Alemayhu <alexander@alemayhu.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57490 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1172619AbdDXOho (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 10:37:44 -0400
In-Reply-To: <20170424133108.31595-2-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2017 03:31 PM, Alexander Alemayhu wrote:
> I was initially going to remove '-Wno-address-of-packed-member' because I
> thought it was not supposed to be there but Daniel suggested using
> '-Wno-unknown-warning-option'.
>
> This silences several warnings similiar to the one below
>
> warning: unknown warning option '-Wno-address-of-packed-member' [-Wunknown-warning-option]
> 1 warning generated.

Yeah, that feature seems fairly new (Feb 2017 accepted if I
see this correctly): https://reviews.llvm.org/D20561

Given the -Wno-address-of-packed-member was there to silence
warnings in the first place, we should also silence warnings
when -Wno-address-of-packed-member is unknown to clang/llvm.

[...]
>
> Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
