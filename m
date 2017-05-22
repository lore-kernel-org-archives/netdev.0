From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] samples/bpf: add samples for HW_CACHE /
 RAW events
Date: Mon, 22 May 2017 19:40:41 -0400 (EDT)
Message-ID: <20170522.194041.936213399075786231.davem@davemloft.net>
References: <20170522224840.810121-3-ast@fb.com>
        <20170522.192651.252662920166760334.davem@davemloft.net>
        <63c0ec55-9cb7-50a0-2020-fe17283e532b@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, bgregg@netflix.com, daniel@iogearbox.net,
        qinteng@fb.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57246 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760212AbdEVXkt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 19:40:49 -0400
In-Reply-To: <63c0ec55-9cb7-50a0-2020-fe17283e532b@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 22 May 2017 16:35:07 -0700

> yet perf_event_read() is least documented. hmm.
>  * u64 bpf_perf_event_read(&map, index)
>  *     Return: Number events read or error code
> 
> that needs to be fixed.

That's exactly what I was talking about :-)
