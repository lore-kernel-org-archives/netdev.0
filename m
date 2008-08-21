From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Thu, 21 Aug 2008 08:47:58 +0000
Message-ID: <20080821084758.GA3510@ff.dom.local>
References: <20080821061024.GA721@gondor.apana.org.au> <20080821064941.GA2764@ff.dom.local> <20080821071634.GA1269@gondor.apana.org.au> <20080821.005250.117238212.davem@davemloft.net> <20080821082721.GA3135@ff.dom.local> <20080821083506.GB3135@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:27201 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630AbYHUIsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 04:48:05 -0400
Received: by nf-out-0910.google.com with SMTP id d3so419980nfc.21
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 01:48:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821083506.GB3135@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 08:35:06AM +0000, Jarek Poplawski wrote:
> On Thu, Aug 21, 2008 at 08:27:21AM +0000, Jarek Poplawski wrote:
> ...
> > Probably it's too early in the morning, 
> 
> It's for sure...
> 
> > BTW, it looks like currently we do this wrong: if it's really
> > dectivated we're checking &noop_qdisc for this...
> 
> ...and it's OK, yet.

Anyway, it's tricky: we have 2 deactivation cases to care for:

1) a "real" (sleeping) qdisc and __QDISC_STATE_DEACTIVATED
2) a &noop_qdisc and not __QDISC_STATE_DEACTIVATED

Jarek P.
