From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 21:07:07 -0400
Message-ID: <1154999227.5138.11.camel@jzny2>
References: <1154867083.6269.35.camel@jzny2>
	 <1154867589.6269.40.camel@jzny2>
	 <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
	 <1154955036.5246.32.camel@jzny2>
	 <20060807152126.GL24653@edgar.underground.se.axis.com>
	 <1154965249.5446.15.camel@jzny2>
	 <20060807155929.GM24653@edgar.underground.se.axis.com>
	 <1154968319.5446.30.camel@jzny2>
	 <20060807170403.GA10818@edgar.underground.se.axis.com>
	 <1154973625.5446.56.camel@jzny2>
	 <20060807184748.GA10909@edgar.underground.se.axis.com>
	 <1154977413.5446.83.camel@jzny2>
	 <Pine.WNT.4.63.0608071350510.3576@jbrandeb-desk.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:49634 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751004AbWHHBHO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 21:07:14 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GAG40-000082-Ez
	for netdev@vger.kernel.org; Mon, 07 Aug 2006 21:07:20 -0400
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.WNT.4.63.0608071350510.3576@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-08 at 13:53 -0700, Brandeburg, Jesse wrote:

> we don't enable it right now, but you could use the TXQE (tx queue empty) 
> interrupt to avoid the starvation case.  I think it might flood you with 
> TXQE interrupts however, so we'd probably have to figure out some way to 
> turn it on occasionally.
> 

I think it may make sense to set on netif_stop and reset on wake. I take
it "empty" means all the descriptors for sending are gone?

cheers,
jamal

