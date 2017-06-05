From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/3] bpf: Add BPF support to all perf_event
Date: Sun, 04 Jun 2017 21:49:02 -0400 (EDT)
Message-ID: <20170604.214902.1742081587444351722.davem@davemloft.net>
References: <20170603040354.3580555-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, bgregg@netflix.com, daniel@iogearbox.net,
        qinteng@fb.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751189AbdFEBtF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 21:49:05 -0400
In-Reply-To: <20170603040354.3580555-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Fri, 2 Jun 2017 21:03:51 -0700

> v3->v4: one more tweak to reject unsupported events at map
> update time as Peter suggested
> 
> v2->v3: more refactoring to address Peter's feedback.
> Now all perf_events are attachable and readable
> 
> v1->v2: address Peter's feedback. Refactor patch 1 to allow attaching
> bpf programs to all event types and reading counters from all of them as well
> patch 2 - more tests
> patch 3 - address Dave's feedback and document bpf_perf_event_read()
> and bpf_perf_event_output() properly

Series applied, thanks.
