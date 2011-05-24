From: David Miller <davem@davemloft.net>
Subject: Re: bridge netfilter output bug on 2.6.39
Date: Tue, 24 May 2011 13:49:29 -0400 (EDT)
Message-ID: <20110524.134929.1283794053649729358.davem@davemloft.net>
References: <1306254457.3026.69.camel@edumazet-laptop>
	<1306255587.3026.76.camel@edumazet-laptop>
	<20110524104022.212b0b71@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095Ab1EXRti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:49:38 -0400
In-Reply-To: <20110524104022.212b0b71@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 24 May 2011 10:40:22 -0700

> I think there should be BUG_ON any calls to dst_metric_set where
> dst has no metrics available.

Yeah I'll add this too, we can kill it later after we're sure that
we've snuffed out all of these kinds of bugs.

Thanks.
