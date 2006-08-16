From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 14:05:59 +0200
Message-ID: <20060816120559.GZ14627@postel.suug.ch>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au> <20060816105856.GW14627@postel.suug.ch> <20060816111240.GA28846@gondor.apana.org.au> <20060816114003.GY14627@postel.suug.ch> <20060816115747.GA29440@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hasso@estpak.ee, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:8338 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751127AbWHPMFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 08:05:38 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060816115747.GA29440@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Herbert Xu <herbert@gondor.apana.org.au> 2006-08-16 21:57
> On Wed, Aug 16, 2006 at 01:40:03PM +0200, Thomas Graf wrote:
> > 
> > It was added to help quagga identify which route modifications
> > are self caused. It's not possible to use rtm_protocol for this
> > purpose as other applications can delete routes added by quagga.
> 
> Actually it's not that bad.  I just checked the quagga source and
> the stuff it needs was already provided anyway, even before that
> change.

If I recall correctly the quagga folks asked to get the same
behaviour for IPv6 routes as it was already done for IPv4
around the time of that bogus changeset.


> In fact, the really bad bits in the changeset have already been
> reverted by Alexey back in February :)

Right, but he forgot the bits in IPv6 which I now fixed. The
changeset introducing those current->pid uses was definitely
simply wrong. I'm not questioning that :)
