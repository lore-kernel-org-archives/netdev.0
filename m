From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH RFC] pkt_sched: Remove smp_wmb() in qdisc_watchdog()
Date: Fri, 19 Dec 2008 18:18:51 -0800
Message-ID: <20081219181851.7cda3fc1@extreme>
References: <20081219113047.GA17826@ff.dom.local>
	<20081219114125.GB17826@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55930 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833AbYLTCTX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 21:19:23 -0500
In-Reply-To: <20081219114125.GB17826@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Dec 2008 11:41:25 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Fri, Dec 19, 2008 at 11:30:47AM +0000, Jarek Poplawski wrote:
> ...
> > While implementing a TCQ_F_THROTTLED flag there was used an smp_wmb()
> > in qdisc_watchdog(), but since this flag is practically used only in
> > sch_netem(), and since it's not even clear what reordering is avoided
> 
> Hmm.. I forgot to mention sch_cbq(), but it doesn't use a barrier
> anyway.
> 
> Jarek P.

The barrier was copied from earlier version of tbf is unnecessary.
