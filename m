From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next 03/10] perf: split perf_trace_buf_prepare
 into alloc and update parts
Date: Thu, 7 Apr 2016 22:58:00 +0200
Message-ID: <20160407205800.GH3448@twins.programming.kicks-ass.net>
References: <1459993411-2754735-1-git-send-email-ast@fb.com>
 <1459993411-2754735-4-git-send-email-ast@fb.com>
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
In-Reply-To: <1459993411-2754735-4-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2016 at 06:43:24PM -0700, Alexei Starovoitov wrote:
> split allows to move expensive update of 'struct trace_entry' to later phase.
> Repurpose unused 1st argument of perf_tp_event() to indicate event type.
> 
> While splitting use temp variable 'rctx' instead of '*rctx' to avoid
> unnecessary loads done by the compiler due to -fno-strict-aliasing
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
