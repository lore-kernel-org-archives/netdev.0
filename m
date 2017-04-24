From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/3] samples/bpf: check before defining offsetof
Date: Mon, 24 Apr 2017 16:41:26 +0200
Message-ID: <58FE0E96.9020403@iogearbox.net>
References: <20170424133108.31595-1-alexander@alemayhu.com> <20170424133108.31595-4-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com
To: Alexander Alemayhu <alexander@alemayhu.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58302 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1172642AbdDXOl3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 10:41:29 -0400
In-Reply-To: <20170424133108.31595-4-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2017 03:31 PM, Alexander Alemayhu wrote:
> Fixes the following warning
>
> samples/bpf/test_lru_dist.c:28:0: warning: "offsetof" redefined
>   #define offsetof(TYPE, MEMBER) ((size_t)&((TYPE *)0)->MEMBER)
>
> In file included from ./tools/lib/bpf/bpf.h:25:0,
>                   from samples/bpf/libbpf.h:5,
>                   from samples/bpf/test_lru_dist.c:24:
> /usr/lib/gcc/x86_64-redhat-linux/6.3.1/include/stddef.h:417:0: note: this is the location of the previous definition
>   #define offsetof(TYPE, MEMBER) __builtin_offsetof (TYPE, MEMBER)
>
> Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
