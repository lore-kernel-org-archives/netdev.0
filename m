From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next 02/10] perf: remove unused __addr variable
Date: Thu, 7 Apr 2016 22:54:30 +0200
Message-ID: <20160407205430.GG3448@twins.programming.kicks-ass.net>
References: <1459993411-2754735-1-git-send-email-ast@fb.com>
 <1459993411-2754735-3-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1459993411-2754735-3-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2016 at 06:43:23PM -0700, Alexei Starovoitov wrote:
> now all calls to perf_trace_buf_submit() pass 0 as 4th
> argument which will be repurposed in the next patch which will
> change the meaning of 1st arg of perf_tp_event() to event_type
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  include/trace/perf.h         | 7 ++-----
>  include/trace/trace_events.h | 3 ---
>  2 files changed, 2 insertions(+), 8 deletions(-)
> 
> diff --git a/include/trace/perf.h b/include/trace/perf.h
> index 26486fcd74ce..6f7e37869065 100644
> --- a/include/trace/perf.h
> +++ b/include/trace/perf.h
> @@ -20,9 +20,6 @@
>  #undef __get_bitmask
>  #define __get_bitmask(field) (char *)__get_dynamic_array(field)
>  
> -#undef __perf_addr
> -#define __perf_addr(a)	(__addr = (a))
> -

Ah, we're not using that anylonger..

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
