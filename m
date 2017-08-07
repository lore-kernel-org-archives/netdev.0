From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/2] bpf: add support for
 sys_{enter|exit}_* tracepoints
Date: Mon, 07 Aug 2017 14:10:12 -0700 (PDT)
Message-ID: <20170807.141012.1406184213867808884.davem@davemloft.net>
References: <20170804230010.2792119-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, rostedt@goodmis.org, ast@fb.com,
        daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: yhs@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36140 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdHGVKN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:10:13 -0400
In-Reply-To: <20170804230010.2792119-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@fb.com>
Date: Fri, 4 Aug 2017 16:00:08 -0700

> Currently, bpf programs cannot be attached to sys_enter_* and sys_exit_*
> style tracepoints. The main reason is that syscalls/sys_enter_* and syscalls/sys_exit_*
> tracepoints are treated differently from other tracepoints and there
> is no bpf hook to it.
> 
> This patch set adds bpf support for these syscalls tracepoints and also
> adds a test case for it.
> 
> Changelogs:
> v3 -> v4:
>  - Check the legality of ctx offset access for syscall tracepoint as well.
>    trace_event_get_offsets will return correct max offset for each
>    specific syscall tracepoint.
>  - Use variable length array to avoid hardcode 6 as the maximum
>    arguments beyond syscall_nr.
> v2 -> v3:
>  - Fix a build issue
> v1 -> v2:
>  - Do not use TRACE_EVENT_FL_CAP_ANY to identify syscall tracepoint.
>    Instead use trace_event_call->class.

Series applied, thank you.
