From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: Initialize sk_hash to random value
 and reset for failing cnxs
Date: Wed, 29 Jul 2015 22:44:25 -0700 (PDT)
Message-ID: <20150729.224425.1379768122818684246.davem@davemloft.net>
References: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbbG3Fo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 01:44:26 -0400
In-Reply-To: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 28 Jul 2015 16:02:04 -0700

> This patch set implements a common function to simply set sk_txhash to
> a random number instead of going through the trouble to call flow
> dissector. From dst_negative_advice we now reset the sk_txhash in hopes
> of finding a better ECMP path through the network. Changing sk_txhash
> affects:
>   - IPv6 flow label and UDP source port which affect ECMP in the network
>   - Local EMCP route selection (pending changes to use sk_txhash)

This looks fine, series applied, thanks Tom.
