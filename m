From: David Miller <davem@davemloft.net>
Subject: Re: [0/3] bridge: Do not send multicast queries by default
Date: Fri, 13 Apr 2012 10:53:45 -0400 (EDT)
Message-ID: <20120413.105345.319552552748408545.davem@davemloft.net>
References: <20120413123641.GA758@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49478 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203Ab2DMOxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 10:53:51 -0400
In-Reply-To: <20120413123641.GA758@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Fri, 13 Apr 2012 20:36:41 +0800

> (incidentally, I noticed that our IPv6 code has been "fixed" to not
> use zero source addresses, which is wrong as we may end up being THE
> MLD querier in a network).

I seem to recall it was explicitly changed to be this way and that
there was a good reason for this, see the history.
