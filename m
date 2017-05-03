From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] test_bpf: Use ULL suffix for 64-bit constants
Date: Wed, 03 May 2017 13:34:57 +0200
Message-ID: <5909C061.7090409@iogearbox.net>
References: <1493811064-24542-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, --cc@ramsan.of.borg,
        linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36262 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751923AbdECLfE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 07:35:04 -0400
In-Reply-To: <1493811064-24542-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2017 01:31 PM, Geert Uytterhoeven wrote:
> On 32-bit:
>
>      lib/test_bpf.c:4772: warning: integer constant is too large for ‘unsigned long’ type
>      lib/test_bpf.c:4772: warning: integer constant is too large for ‘unsigned long’ type
>      lib/test_bpf.c:4773: warning: integer constant is too large for ‘unsigned long’ type
>      lib/test_bpf.c:4773: warning: integer constant is too large for ‘unsigned long’ type
>      lib/test_bpf.c:4787: warning: integer constant is too large for ‘unsigned long’ type
>      lib/test_bpf.c:4787: warning: integer constant is too large for ‘unsigned long’ type
>      lib/test_bpf.c:4801: warning: integer constant is too large for ‘unsigned long’ type
>      lib/test_bpf.c:4801: warning: integer constant is too large for ‘unsigned long’ type
>      lib/test_bpf.c:4802: warning: integer constant is too large for ‘unsigned long’ type
>      lib/test_bpf.c:4802: warning: integer constant is too large for ‘unsigned long’ type
>
> On 32-bit systems, "long" is only 32-bit.
> Replace the "UL" suffix by "ULL" to fix this.
>
> Fixes: 85f68fe898320575 ("bpf, arm64: implement jiting of BPF_XADD")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Yep, of course, not sure how I missed it! :/ Thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
