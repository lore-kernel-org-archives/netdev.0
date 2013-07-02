From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Tue, 02 Jul 2013 12:47:50 -0700 (PDT)
Message-ID: <20130702.124750.1357592020126802332.davem@davemloft.net>
References: <1372747174-23580-1-git-send-email-fan.du@windriver.com>
	<51D2E3C8.5050100@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fan.du@windriver.com, nhorman@tuxdriver.com,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231Ab3GBTrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 15:47:51 -0400
In-Reply-To: <51D2E3C8.5050100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Tue, 02 Jul 2013 10:29:28 -0400

> I think it would be better if we stored the dst_cookie in the
> transport structure and initialized it at lookup time.

Agreed, that is the proper fix for this problem.
