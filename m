From: David Miller <davem@davemloft.net>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 19:07:23 -0800 (PST)
Message-ID: <20110225.190723.39180243.davem@davemloft.net>
References: <20110226005718.GA19889@gondor.apana.org.au>
	<20110225.181244.104056532.davem@davemloft.net>
	<20110226024848.GA20993@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, tgraf@infradead.org, therbert@google.com,
	wsommerfeld@google.com, daniel.baluta@gmail.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56352
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750885Ab1BZDGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 22:06:46 -0500
In-Reply-To: <20110226024848.GA20993@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 26 Feb 2011 10:48:48 +0800

> I'm looking at redoing this and the bulk of the work is going to
> be restructuring ip_append_data/ip_push_pending_frames so that it
> doesn't store the states in sk/inet_sk.

I suppose you're going to replace that stuff with an on-stack
control structure that gets passed around by reference or
similar?
