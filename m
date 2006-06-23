From: jamal <hadi@cyberus.ca>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Thu, 22 Jun 2006 20:52:17 -0400
Message-ID: <1151023937.5099.40.camel@jzny2>
References: <20060619121519.GA16031@gondor.apana.org.au>
	 <1150724031.5815.39.camel@jzny2>
	 <20060619134227.GA16662@gondor.apana.org.au>
	 <1150727009.5815.72.camel@jzny2>
	 <20060619142928.GA17191@gondor.apana.org.au>
	 <1150727810.5815.78.camel@jzny2>
	 <20060619223326.GA20354@gondor.apana.org.au>
	 <1150814526.5270.64.camel@jzny2>
	 <20060620235207.GA31493@gondor.apana.org.au>
	 <1151004682.5392.97.camel@jzny2>
	 <20060622224302.GA10136@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:49073 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751090AbWFWAwU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 20:52:20 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FtZuN-0000uO-0F
	for netdev@vger.kernel.org; Thu, 22 Jun 2006 20:52:27 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060622224302.GA10136@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-23-06 at 08:43 +1000, Herbert Xu wrote:

> Sure.  However, I still don't see the point of transmitting in parallel
> even there.  The reason is that there is no work being done here by the
> CPU between dequeueing the packet and obtaining the TX lock.

You make a reasonable argument. 
I think I will need to run the experiment to gather facts. I will defer
this discussion until i run some tests or Robert beats me to it.

It does feel like the qdisc_is_running though is now a replacement
for the need for dev->txlock which existed to protect multi-cpus from
entering the device transmit path. Is that unintended side effect?
i.e why would dev->txlock be needed anymore in that path?

cheers,
jamal


