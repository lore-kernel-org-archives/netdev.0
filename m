From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] ipv6: let trace_fib6_table_lookup() dereference
 the fib table
Date: Thu, 19 Oct 2017 10:26:13 -0700
Message-ID: <20171019172613.cewlo6ctggzmauyi@kafai-mbp.dhcp.thefacebook.com>
References: <48235df8fdf787356070d8baa1ac9816ef5736d4.1508398120.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39798 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751087AbdJSR0Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 13:26:24 -0400
Content-Disposition: inline
In-Reply-To: <48235df8fdf787356070d8baa1ac9816ef5736d4.1508398120.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 07:31:43AM +0000, Paolo Abeni wrote:
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
Acked-by: Martin KaFai Lau <kafai@fb.com>
