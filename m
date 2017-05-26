From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/3] perf, bpf: Add BPF support to all
 perf_event types
Date: Fri, 26 May 2017 10:55:33 -0400 (EDT)
Message-ID: <20170526.105533.1718406512698133332.davem@davemloft.net>
References: <20170526055549.557818-1-ast@fb.com>
        <20170526055549.557818-2-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, bgregg@netflix.com, daniel@iogearbox.net,
        qinteng@fb.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41060 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939021AbdEZOzf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:55:35 -0400
In-Reply-To: <20170526055549.557818-2-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 25 May 2017 22:55:47 -0700

> +	if (event->attach_state & PERF_ATTACH_TASK)
> +		goto err_out;

The attach_state member only exists when PERF_EVENTS is enabled.
