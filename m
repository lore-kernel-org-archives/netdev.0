From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 20:52:01 -0400
Message-ID: <1154998321.5138.7.camel@jzny2>
References: <20060807152126.GL24653@edgar.underground.se.axis.com>
	 <1154965249.5446.15.camel@jzny2>
	 <20060807155929.GM24653@edgar.underground.se.axis.com>
	 <1154968319.5446.30.camel@jzny2>
	 <20060807170403.GA10818@edgar.underground.se.axis.com>
	 <1154973625.5446.56.camel@jzny2>
	 <20060807184748.GA10909@edgar.underground.se.axis.com>
	 <1154977413.5446.83.camel@jzny2>
	 <20060807191413.GB10909@edgar.underground.se.axis.com>
	 <1154979270.5446.97.camel@jzny2>
	 <20060807202826.GC10909@edgar.underground.se.axis.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:39866 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932278AbWHHAwF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 20:52:05 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GAFpL-0003QD-Ky
	for netdev@vger.kernel.org; Mon, 07 Aug 2006 20:52:11 -0400
To: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
In-Reply-To: <20060807202826.GC10909@edgar.underground.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-08 at 22:28 +0200, Edgar E. Iglesias wrote:

> 
> I can see two calls to e1000_prune_tx_ring with jamal _defined_.
> 

Ok, never mind - I think thats the source of our confusion. Just ignore
those entries since they are ifdefed out (The second one i dont know how
it made it in since there are no traces of it in my tree).

cheers,
jamal

