From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Mon, 06 Feb 2012 12:18:26 -0500
Message-ID: <1328548706.2200.17.camel@gandalf.stny.rr.com>
References: <20120120.135028.1359677274445012541.davem@davemloft.net>
	 <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
	 <20120204142823.GA7000@neilslaptop.think-freely.org>
	 <20120204155807.GA2657@nuttenaction>
	 <20120204200937.GA2670@neilslaptop.think-freely.org>
	 <20120205125325.GA31578@elastic.org>
	 <20120205191708.GA5337@neilslaptop.think-freely.org>
	 <20120205200428.GB2816@nuttenaction>
	 <20120206013247.GA5681@neilslaptop.think-freely.org>
	 <20120206152019.GG27935@redhat.com>
	 <20120206155305.GB3620@hmsreliant.think-freely.org>
	 <1328545089.2200.13.camel@gandalf.stny.rr.com>
	 <1328547754.2220.86.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"Frank Ch. Eigler" <fche@redhat.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	"Frank Ch. Eigler" <fche@elastic.org>,
	Satoru Moriya <satoru.moriya@hds.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>, fche@sourceware.org,
	mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.123]:58210 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754464Ab2BFRS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 12:18:29 -0500
In-Reply-To: <1328547754.2220.86.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-06 at 18:02 +0100, Eric Dumazet wrote:
>  
> > I haven't looked at the details here, but I'm wondering if netfilter
> > could benefit from static_branch() calls (aka jump-labels). I'm sure
> > selinux could too. Basically, when netfilter is disabled, the fast path
> > would just include a nop, with no if() branch testing at all. When you
> > enable netfilters, it would then add a jmp to the code that actually
> > does the tests.
> 
> Hmm... I thought I already did that.
> 
> Or maybe I intended so and forgot.
> 
> Ah no, its there in commit a2d7ec58ac09
> (netfilter: use jump_label for nf_hooks)

hehe, this shows the fact that "I haven't looked at the details here".

;-)

Great to hear!

-- Steve
