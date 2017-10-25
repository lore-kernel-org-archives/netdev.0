From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] bpf: permit multiple bpf attachments
 for a single perf tracepoint event
Date: Wed, 25 Oct 2017 10:48:05 +0900 (KST)
Message-ID: <20171025.104805.1908008846083674759.davem@davemloft.net>
References: <20171024065309.2401893-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, rostedt@goodmis.org, ast@fb.com,
        daniel@iogearbox.net, kafai@fb.com, netdev@vger.kernel.org,
        kernel-team@fb.com
To: yhs@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdJYBsK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 21:48:10 -0400
In-Reply-To: <20171024065309.2401893-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@fb.com>
Date: Mon, 23 Oct 2017 23:53:06 -0700

> This patch set adds support to permit multiple bpf prog attachments
> for a single perf tracepoint event. Patch 1 does some cleanup such
> that perf_event_{set|free}_bpf_handler is called under the
> same condition. Patch 2 has the core implementation, and
> Patch 3 adds a test case.
> 
> Changelogs:
> v2 -> v3:
>   . fix compilation error.
> v1 -> v2:
>   . fix a potential deadlock issue discovered by Daniel.
>   . fix some coding style issues.

Series applied.
