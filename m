From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 21:33:52 -0400
Message-ID: <1155000832.5138.31.camel@jzny2>
References: <20060804110829.62136ebb@dxpl.pdx.osdl.net>
	 <20060804.163111.85390037.davem@davemloft.net>
	 <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
	 <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
	 <1154867083.6269.35.camel@jzny2> <1154999971.5138.19.camel@jzny2>
	 <20060808012217.GA12468@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:51425 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751167AbWHHBd4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 21:33:56 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GAGTq-000604-AN
	for netdev@vger.kernel.org; Mon, 07 Aug 2006 21:34:02 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060808012217.GA12468@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 11:22 +1000, Herbert Xu wrote:

> I'm not sure if this is safe.  What if the other side clears QDISC_RUNNING
> right after you test it here? Wouldn't you miss the schedule altogether?
> 

Is there a need for a schedule if that happens? i.e assuming that the
clearing happens because there are no more packets to process. 
OTOH, if the other side sets the QDISC_RUNNING right after the test,
then qdisc is running will be entered.

cheers,
jamal

