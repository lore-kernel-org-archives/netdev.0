From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 21:35:36 -0400
Message-ID: <1181266536.4741.27.camel@localhost>
References: <1181253445.4071.4.camel@localhost>
	 <20070607.154421.109060486.davem@davemloft.net>
	 <1181256848.4071.57.camel@localhost>
	 <20070607.160035.00774597.davem@davemloft.net>
	 <1181262703.3688.10.camel@w-sridhar2.beaverton.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	jeff@garzik.org, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.228]:55241 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934164AbXFHBfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 21:35:42 -0400
Received: by hu-out-0506.google.com with SMTP id 19so435128hue
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 18:35:41 -0700 (PDT)
In-Reply-To: <1181262703.3688.10.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-06 at 17:31 -0700, Sridhar Samudrala wrote:

> If the QDISC_RUNNING flag guarantees that only one CPU can call
> dev->hard_start_xmit(), then why do we need to hold netif_tx_lock
> for non-LLTX drivers?

I havent stared at other drivers, but for e1000 seems to me 
even if you got rid of LLTX that netif_tx_lock is unnecessary.
Herbert?

cheers,
jamal

