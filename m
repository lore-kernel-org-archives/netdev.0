From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] ipv6: let trace_fib6_table_lookup() dereference
 the fib table
Date: Thu, 19 Oct 2017 09:38:27 -0600
Message-ID: <5462ed72-5180-3e10-c5d9-37762207653f@cumulusnetworks.com>
References: <48235df8fdf787356070d8baa1ac9816ef5736d4.1508398120.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:44159 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752586AbdJSPi3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 11:38:29 -0400
Received: by mail-pf0-f194.google.com with SMTP id x7so6851317pfa.1
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 08:38:29 -0700 (PDT)
In-Reply-To: <48235df8fdf787356070d8baa1ac9816ef5736d4.1508398120.git.pabeni@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/17 1:31 AM, Paolo Abeni wrote:
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
>  include/trace/events/fib6.h |  6 +++---
>  net/ipv6/route.c            | 12 ++++++------
>  2 files changed, 9 insertions(+), 9 deletions(-)

Makes sense.

Acked-by: David Ahern <dsa@cumulusnetworks.com>
