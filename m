From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM][RFC v1] Fix unexpected SA hard expiration after setting
 new date
Date: Tue, 19 Jun 2012 00:34:22 -0700 (PDT)
Message-ID: <20120619.003422.1109786261235176550.davem@davemloft.net>
References: <1340007856-27651-1-git-send-email-fan.du@windriver.com>
	<20120618084021.GA24902@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fan.du@windriver.com, netdev@vger.kernel.org, fdu@windriver.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab2FSHeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 03:34:23 -0400
In-Reply-To: <20120618084021.GA24902@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 18 Jun 2012 16:40:21 +0800

> I guess I can live with your workaround if Dave is happy with
> it.  But IMHO we should just go back to relative time and fix
> the suspend/resume user-space scripts instead.

In the short term I'm happy with it too.

But I seem to remember that last time this issue came up the
suggestion was to use highres timers.  Someone tried but they did an
amazingly poor job so the effort just died off.  It takes someone with
some skill because highres timers operate with different context
requirements than normal timers.
