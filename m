From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] trace_events: fix napi's tracepoint
Date: Wed, 26 Aug 2009 13:20:18 +0800
Message-ID: <4A94C612.60200@cn.fujitsu.com>
References: <4A937EF5.4040505@cn.fujitsu.com> <4A93895F.4010708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49671 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752722AbZHZFUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 01:20:52 -0400
In-Reply-To: <4A93895F.4010708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Xiao Guangrong wrote:
> Currently, the napi's tracepoint works will is depend on
> "DECLARE_TRACE" definiens in include/trace/define_trace.h,
> like below:
> 
> #include <trace/events/skb.h>    // include define_trace.h
> #include <trace/events/napi.h>
> 
> there have error, if we remove "#include <trace/events/skb.h>"
> or include napi.h in the front of include skb.h, It should
> depend on the definiens in include/linux/tracepoint.h and we
> can remove the "DECLARE_TRACE" definiens in
> include/trace/define_trace.h, because "TRACE_EVENT" not use it
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>

Hi Steven,

I'm sorry, please pull this patch too, because 
"[PATCH 7/8] tracing/events: fix the include file dependencies" 
is based on this patch, else will occur building error.

Thanks,
Xiao
