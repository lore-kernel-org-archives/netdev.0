From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.6)
Date: Wed, 12 Jan 2011 09:27:39 -0800
Message-ID: <20110112092739.4cdcb6f4@nehalam>
References: <20110104162930.6fa672e3@nehalam>
	<1294208375.3420.46.camel@edumazet-laptop>
	<20110105091718.02f8a00f@nehalam>
	<1294248332.10633.25.camel@edumazet-laptop>
	<20110105112104.64ad3c86@nehalam>
	<1294286850.2723.65.camel@edumazet-laptop>
	<20110106205549.0de56de1@nehalam>
	<1294667210.3491.7.camel@edumazet-laptop>
	<20110110154414.53f33916@nehalam>
	<1294704031.4148.2.camel@edumazet-laptop>
	<20110110171047.0796b6fb@nehalam>
	<1294726715.4148.8.camel@edumazet-laptop>
	<1294727650.4148.20.camel@edumazet-laptop>
	<1294816428.3447.106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33004 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753457Ab1ALR1m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 12:27:42 -0500
In-Reply-To: <1294816428.3447.106.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Jan 2011 08:13:48 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Hi Stephen, here is my v0.6 version :
> 
> - Added sanity checks before kcalloc()/kzalloc()
> - Added a __GFP_NOWARN to kcalloc()
> - Added call to qdisc_bstats_update() after commit bfe0d0298f2a67d94d5
> (net_sched: factorize qdisc stats handling)
> 
> TODO :
> - Added a stat specific update to track CHOKe probabilistic dual-drops
>   I temporarily use requeues counter to make sure our code works

I am going to redo stats and config.
Should thresholds be packet or byte based? I prefer packet
Also leaning towards merging qmax and qlimit together.
