From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 6/8] percpu: add __percpu sparse annotations to trace
Date: Mon, 25 Jan 2010 10:35:36 -0500
Message-ID: <1264433736.31321.413.camel@gandalf.stny.rr.com>
References: <1264432935-10453-1-git-send-email-tj@kernel.org>
	 <1264432935-10453-7-git-send-email-tj@kernel.org>
Reply-To: rostedt@goodmis.org
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, viro@zeniv.linux.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org, x86@kernel.org,
	mingo@redhat.com, fweisbec@gmail.com, dan.j.williams@intel.com,
	borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org,
	neilb@suse.de, cl@linux-foundation.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.123]:41865 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932131Ab0AYPfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 10:35:41 -0500
In-Reply-To: <1264432935-10453-7-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-26 at 00:22 +0900, Tejun Heo wrote:
> Add __percpu sparse annotations to trace.
> 
> These annotations are to make sparse consider percpu variables to be
> in a different address space and warn if accessed without going
> through percpu accessors.  This patch doesn't affect normal builds.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

> Cc: Frederic Weisbecker <fweisbec@gmail.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> ---
>  include/linux/ftrace_event.h         |    4 ++--
>  include/trace/ftrace.h               |    4 ++--
>  kernel/trace/trace_event_profile.c   |   16 ++++++++--------
>  kernel/trace/trace_functions_graph.c |    2 +-
>  kernel/trace/trace_kprobe.c          |    4 ++--
>  kernel/trace/trace_ksym.c            |   10 +++++-----
>  kernel/trace/trace_syscalls.c        |    4 ++--
>  7 files changed, 22 insertions(+), 22 deletions(-)
> 


