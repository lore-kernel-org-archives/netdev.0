From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net] bpf: one perf event close won't free bpf program
 attached by another perf event
Date: Thu, 21 Sep 2017 10:02:22 -0400
Message-ID: <20170921100222.18c03ab6@gandalf.local.home>
References: <20170918233836.1817062-1-yhs@fb.com>
        <20170920214109.11002b7c@vmware.local.home>
        <94f5a61e-1a88-f285-224b-66c92dc3da7b@fb.com>
        <9e968490-87ae-7a79-9e59-0dcc840a93f5@fb.com>
        <20170921111706.343om7252gcagco6@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yonghong Song <yhs@fb.com>, ast@fb.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, kernel-team@fb.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:51900 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751593AbdIUOCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 10:02:25 -0400
In-Reply-To: <20170921111706.343om7252gcagco6@hirez.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Sep 2017 13:17:06 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> I suspect that would break a fair bunch of bpf proglets, since the data
> access to the trace data would be completely different, but it would be
> much nicer to not have this distinction based on event type.

Maybe this would be a good test to see if bpf is considered an ABI or
not.

-- Steve
