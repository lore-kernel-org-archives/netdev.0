From: "Frank Ch. Eigler" <fche@redhat.com>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Mon, 6 Feb 2012 11:21:36 -0500
Message-ID: <20120206162136.GJ27935@redhat.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com> <20120204142823.GA7000@neilslaptop.think-freely.org> <20120204155807.GA2657@nuttenaction> <20120204200937.GA2670@neilslaptop.think-freely.org> <20120205125325.GA31578@elastic.org> <20120205191708.GA5337@neilslaptop.think-freely.org> <20120205200428.GB2816@nuttenaction> <20120206013247.GA5681@neilslaptop.think-freely.org> <20120206152019.GG27935@redhat.com> <20120206155305.GB3620@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	"Frank Ch. Eigler" <fche@elastic.org>,
	Satoru Moriya <satoru.moriya@hds.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>, fche@sourceware.org,
	mathieu.desnoyers@polymtl.ca, rostedt@goodmis.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754852Ab2BFQWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Feb 2012 11:22:37 -0500
Content-Disposition: inline
In-Reply-To: <20120206155305.GB3620@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

On Mon, Feb 06, 2012 at 10:53:05AM -0500, Neil Horman wrote:

> [...] If you're unfamiliar with them, netfilter hooks are those
> standard points in the network input/output/forwarding paths at
> which we can watch and maniupulate network traffic.  [...]

Aha, nf_register_hook and friends.  Thanks for the pointer.

> > Does this mean that this netfilter hook mechanism is sufficient to
> > adapt to the current/future diversity of behaviors?  Why not make
> > *that* into a tracepoint then, so perf/stap scripts could get at it in
> > userspace?

> I suppose you could.  [...]  I'm suggesting a kernel module because
> then you wouldn't have the performance overhead of moving all those
> frames to user space.

(For what it's worth, if there were a tracepoint in the netfilter 
hook machinery, stap would be able to process the packets likewise,
in-kernel, with no kernel debuginfo installed.)

- FChE
