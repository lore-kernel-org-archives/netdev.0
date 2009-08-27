From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: Re: [PATCH 3/3] tracing/events: convert NAPI's tracepoint and fix
 DEFINE_TRACE_FN
Date: Thu, 27 Aug 2009 18:49:38 +0800
Message-ID: <4A9664C2.3000004@cn.fujitsu.com>
References: <4A96635C.9070404@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56974 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751085AbZH0KuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 06:50:11 -0400
In-Reply-To: <4A96635C.9070404@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Xiao Guangrong wrote:
> References: <4A966288.8020402@cn.fujitsu.com>
> In-Reply-To: <4A966288.8020402@cn.fujitsu.com>
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 7bit
> 

It's look like my mail client has some problems, I'll check it and resend
this mail. Sorry!

Thanks,
Xiao

> - Convert NAPI's tracepoint via TRACE_EVENT macro, the output information
>   like below:
> 
>    sshd-2503  [000]    71.920846: napi_poll: ifname=eth0 state=0 weigth=16 poll=pcnet32_poll
>    sshd-2503  [000]    72.020291: napi_poll: ifname=eth0 state=0 weigth=16 poll=pcnet32_poll
>    sshd-2503  [000]    72.020418: napi_poll: ifname=eth0 state=NAPI_STATE_SCHED weigth=16 poll=pcnet32_poll
> 
> - Remove the "DECLARE_TRACE" definiens in include/trace/define_trace.h,
>   because TRACE_EVENT not use it
> 
> - Undef DEFINE_TRACE_FN after TRACE_EVENT/TRACE_EVENT_FN expanded,
>   then we can include more TRACE_EVENT .h file in one .c file
>   (the .c file has defined CREATE_TRACE_POINTS)
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>

