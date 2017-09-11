From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] perf/bpf: fix a clang compilation issue
Date: Mon, 11 Sep 2017 14:28:57 -0700 (PDT)
Message-ID: <20170911.142857.1205848546110018404.davem@davemloft.net>
References: <20170908013615.973478-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, rostedt@goodmis.org, ast@fb.com,
        daniel@iogearbox.net, ndesaulniers@google.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: yhs@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56246 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdIKV27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 17:28:59 -0400
In-Reply-To: <20170908013615.973478-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@fb.com>
Date: Thu, 7 Sep 2017 18:36:15 -0700

> clang does not support variable length array for structure member.
> It has the following error during compilation:
> 
> kernel/trace/trace_syscalls.c:568:17: error: fields must have a constant size:
> 'variable length array in structure' extension will never be supported
>                 unsigned long args[sys_data->nb_args];
>                               ^
> 
> The fix is to use a fixed array length instead.
> 
> Reported-by: Nick Desaulniers <ndesaulniers@google.com>
> Signed-off-by: Yonghong Song <yhs@fb.com>

Applied.
