From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 3/3] tracing/events: convert NAPI's tracepoint and fix
	DEFINE_TRACE_FN
Date: Thu, 27 Aug 2009 08:56:37 -0400
Message-ID: <20090827124713.GB4762@hmsreliant.think-freely.org>
References: <4A96635C.9070404@cn.fujitsu.com> <4A9664C2.3000004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752594AbZH0M4w@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A9664C2.3000004@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 27, 2009 at 06:49:38PM +0800, Xiao Guangrong wrote:
> 
> 
> Xiao Guangrong wrote:
> > References: <4A966288.8020402@cn.fujitsu.com>
> > In-Reply-To: <4A966288.8020402@cn.fujitsu.com>
> > Content-Type: text/plain; charset=UTF-8
> > Content-Transfer-Encoding: 7bit
> > 
> 
> It's look like my mail client has some problems, I'll check it and resend
> this mail. Sorry!
> 
> Thanks,
> Xiao
> 
Please do, thank you!
Neil

> > - Convert NAPI's tracepoint via TRACE_EVENT macro, the output information
> >   like below:
> > 
> >    sshd-2503  [000]    71.920846: napi_poll: ifname=eth0 state=0 weigth=16 poll=pcnet32_poll
> >    sshd-2503  [000]    72.020291: napi_poll: ifname=eth0 state=0 weigth=16 poll=pcnet32_poll
> >    sshd-2503  [000]    72.020418: napi_poll: ifname=eth0 state=NAPI_STATE_SCHED weigth=16 poll=pcnet32_poll
> > 
> > - Remove the "DECLARE_TRACE" definiens in include/trace/define_trace.h,
> >   because TRACE_EVENT not use it
> > 
> > - Undef DEFINE_TRACE_FN after TRACE_EVENT/TRACE_EVENT_FN expanded,
> >   then we can include more TRACE_EVENT .h file in one .c file
> >   (the .c file has defined CREATE_TRACE_POINTS)
> > 
> > Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
> 
> 
