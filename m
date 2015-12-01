From: "PaX Team" <pageexec@freemail.hu>
Subject: Re: size overflow in function qdisc_tree_decrease_qlen net/sched/sch_api.c
Date: Tue, 01 Dec 2015 17:13:10 +0100
Message-ID: <565DC716.22673.2DBA261B@pageexec.freemail.hu>
References: <20151201010005.GA23175@Fux-PC>, <1448978807.25582.19.camel@edumazet-glaptop2.roam.corp.google.com>, <1448979011.25582.21.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: pageexec@freemail.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, spender@grsecurity.net,
	re.emese@gmail.com
To: Daniele Fucini <dfucini@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r00tworld.com ([212.85.137.150]:48552 "EHLO r00tworld.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756131AbbLAQNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 11:13:50 -0500
In-reply-to: <1448979011.25582.21.camel@edumazet-glaptop2.roam.corp.google.com>
Content-description: Mail message body
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 Dec 2015 at 6:10, Eric Dumazet wrote:

> On Tue, 2015-12-01 at 06:06 -0800, Eric Dumazet wrote:
> > On Tue, 2015-12-01 at 12:19 +0100, Daniele Fucini wrote:
> > > Thanks for the reply. Here's the output of `tc qdisc show`:
> > > https://gist.github.com/1847102c8fe08f63e9e7
> 
> > Hmm... I do not think we ever took care of MQ in
> > qdisc_tree_decrease_qlen()
> 
> This looks like a false positive, because MQ recomputes backlog/qlen at
> the time (stats) dumps are requested.
> 
> I would say there is no bug.

is it correct for sk_buff_head.qlen to underflow in general
or just in this particular sched code? (we can exclude overflow
checking for either case but obviously would like to retain as
much coverage as possible)

thanks,
 PaX Team
