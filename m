From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: let trace_fib6_table_lookup()
 dereference the fib table
Date: Sat, 21 Oct 2017 02:23:52 +0100 (WEST)
Message-ID: <20171021.022352.414024597933176809.davem@davemloft.net>
References: <48235df8fdf787356070d8baa1ac9816ef5736d4.1508398120.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rostedt@goodmis.org, mingo@redhat.com,
        dsa@cumulusnetworks.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753104AbdJUBXz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 21:23:55 -0400
In-Reply-To: <48235df8fdf787356070d8baa1ac9816ef5736d4.1508398120.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 19 Oct 2017 09:31:43 +0200

> The perf traces for ipv6 routing code show a relevant cost around
> trace_fib6_table_lookup(), even if no trace is enabled. This is
> due to the fib6_table de-referencing currently performed by the
> caller.
> 
> Let's the tracing code pay this overhead, passing to the trace
> helper the table pointer. This gives small but measurable
> performance improvement under UDP flood.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Looks good, applied.
