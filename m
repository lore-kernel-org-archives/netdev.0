From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] trace_events: fix napi's tracepoint
Date: Wed, 26 Aug 2009 08:49:16 +0800
Message-ID: <4A94868C.4080801@cn.fujitsu.com>
References: <4A937EF5.4040505@cn.fujitsu.com> <4A93895F.4010708@cn.fujitsu.com> <20090825075816.GB857@elte.hu> <20090825105707.GA24710@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932759AbZHZAtt@vger.kernel.org>
In-Reply-To: <20090825105707.GA24710@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Neil Horman wrote:
> On Tue, Aug 25, 2009 at 09:58:16AM +0200, Ingo Molnar wrote:
>> * Xiao Guangrong <xiaoguangrong@cn.fujitsu.com> wrote:
>>
>> This will collide with tracing bits in the networking tree. The 
>> skb-tracing plugin there should be turned into proper TRACE_EVENT() 
>> tracepoints.
>>
>> Neil was away for some time but i think soon we should see some 
>> movement here.
>>
>> 	Ingo
>>
> 
> Thank you Ingo, yes, I'm back from the beach now and will look at this shortly.
> I concur, we should just convert the napi_poll tracepoint to be defined via the
> TRACE_EVENT macro, same as the kfree_skb tracepoint.  Xaio would you like to
> take care of that, or shall I?
>

Hi Neil,

I'm glad to do it.

Actually, we should fix the include file dependencies first
(the second patch in this patchset), else we can't include two
TRACE_EVENT head files in net-traces.c

Steve will pull this patchset, so, I'll convert it after this
patchset merged.
