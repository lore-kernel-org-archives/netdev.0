From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 03 Aug 2006 17:01:43 -0700 (PDT)
Message-ID: <20060803.170143.20633018.davem@davemloft.net>
References: <20060803235326.GC7894@thunk.org>
	<20060803.165654.45876296.davem@davemloft.net>
	<20060803235927.GB10932@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tytso@mit.edu, mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52883
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030239AbWHDABl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 20:01:41 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060803235927.GB10932@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 4 Aug 2006 09:59:27 +1000

> Watchdogs usually require one heartbeat every 30 seconds or so.  Does
> the ASF heartbeat need to be that frequent?

The ASF heartbeat needs to be sent every 2 seconds.
