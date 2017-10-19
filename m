From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next] ipv6: let trace_fib6_table_lookup()
 dereference the fib table
Date: Thu, 19 Oct 2017 09:30:25 -0400
Message-ID: <20171019093025.5a7b9ea2@vmware.local.home>
References: <48235df8fdf787356070d8baa1ac9816ef5736d4.1508398120.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Ingo Molnar <mingo@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0082.hostedemail.com ([216.40.44.82]:56583 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752969AbdJSNa3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 09:30:29 -0400
In-Reply-To: <48235df8fdf787356070d8baa1ac9816ef5736d4.1508398120.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Oct 2017 09:31:43 +0200
Paolo Abeni <pabeni@redhat.com> wrote:

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
> ---

Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve
