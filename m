From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 25 Dec 2008 17:13:25 -0800 (PST)
Message-ID: <20081225.171325.104086356.davem@davemloft.net>
References: <20081217212907.GA27243@gondor.apana.org.au>
	<20081217225231.GA28052@gondor.apana.org.au>
	<20081217231543.GA28459@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, ptesarik@suse.cz, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60273
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752094AbYLZBNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 20:13:23 -0500
In-Reply-To: <20081217231543.GA28459@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 18 Dec 2008 10:15:43 +1100

> tcp: Always set urgent pointer if it's beyond snd_nxt

Ok, I've applied this for 2.6.29
