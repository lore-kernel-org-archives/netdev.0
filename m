From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][af_key]pfkey_add: Optimize SA adds and algorithm probes
Date: Thu, 24 May 2007 17:36:27 -0700 (PDT)
Message-ID: <20070524.173627.98881801.davem@davemloft.net>
References: <E1HouAO-0003i5-00@gondolin.me.apana.org.au>
	<20070518212148.GA25363@gondor.apana.org.au>
	<46562AA2.8030102@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: mhuth@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45937
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750864AbXEYAgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 20:36:24 -0400
In-Reply-To: <46562AA2.8030102@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Huth <mhuth@mvista.com>
Date: Thu, 24 May 2007 17:15:30 -0700

> I'm a bit curious why all of the crypto modules got loaded, but it 
> doesn't matter.

When SADB_REGISTER is performed on a PF_KEY socket, it calls
xfrm_probe_algs() which iterates over the lists and loads all the
availble modules.
