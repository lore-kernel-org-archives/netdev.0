From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Thu, 21 Aug 2008 08:35:06 +0000
Message-ID: <20080821083506.GB3135@ff.dom.local>
References: <20080821061024.GA721@gondor.apana.org.au> <20080821064941.GA2764@ff.dom.local> <20080821071634.GA1269@gondor.apana.org.au> <20080821.005250.117238212.davem@davemloft.net> <20080821082721.GA3135@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:61336 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756251AbYHUIfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 04:35:12 -0400
Received: by ey-out-2122.google.com with SMTP id 6so24232eyi.37
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 01:35:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821082721.GA3135@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 08:27:21AM +0000, Jarek Poplawski wrote:
...
> Probably it's too early in the morning, 

It's for sure...

> BTW, it looks like currently we do this wrong: if it's really
> dectivated we're checking &noop_qdisc for this...

...and it's OK, yet.

Sorry,
Jarek P.
