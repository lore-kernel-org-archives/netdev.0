From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH resend] tracing/events: convert NAPI's tracepoint via
	TRACE_EVENT
Date: Mon, 31 Aug 2009 10:49:22 +0200
Message-ID: <20090831084922.GB25811@elte.hu>
References: <4A9B6AA7.5020508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:56404 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606AbZHaItj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2009 04:49:39 -0400
Content-Disposition: inline
In-Reply-To: <4A9B6AA7.5020508@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Xiao Guangrong <xiaoguangrong@cn.fujitsu.com> wrote:

> - Convert NAPI's tracepoint via TRACE_EVENT macro, the output information
>   like below:

I think as long as it does not touch tracing infrastructure (which 
your patches dont do in their current form) this should be 
done/merged via the networking tree.

[ There might be some small collisions in define_trace.h (because
  these tracepoints move from legacy to new-style TRACE_EVENT() 
  form) but that's OK. ]

	Ingo
