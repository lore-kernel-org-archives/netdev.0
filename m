From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Fix qdisc state in net_tx_action()
Date: Sat, 6 Sep 2008 14:02:17 +0200
Message-ID: <20080906120217.GA2571@ami.dom.local>
References: <20080905082915.GA7320@ff.dom.local> <200809060141.17121.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:28021 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbYIFMCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2008 08:02:23 -0400
Received: by fg-out-1718.google.com with SMTP id 19so940398fgg.17
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2008 05:02:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200809060141.17121.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 06, 2008 at 01:41:17AM +0300, Denys Fedoryshchenko wrote:
> On Friday 05 September 2008, Jarek Poplawski wrote:
> > ------------>
> >
> > pkt_sched: Fix qdisc state in net_tx_action()
> >
> > net_tx_action() can skip __QDISC_STATE_SCHED bit clearing while qdisc
> > is neither ran nor rescheduled, which may cause endless loop in
> > dev_deactivate().
> >
> > Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Tested, working fine, bug fixed.
> 

So, I guess, David could treat this as your "Tested-by:".

Thanks again,
Jarek P.
