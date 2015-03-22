From: David Miller <davem@davemloft.net>
Subject: Re: arp_hash
Date: Sun, 22 Mar 2015 12:54:58 -0400 (EDT)
Message-ID: <20150322.125458.2054837991708165397.davem@davemloft.net>
References: <20150322114204.GA5010@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@purestorage.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbbCVQzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 12:55:03 -0400
In-Reply-To: <20150322114204.GA5010@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 22 Mar 2015 22:42:04 +1100

> If the attacker can somehow get the pointer value of the device
> then all is lost since they could set any number of the low bits
> of val to zero.

This "attacker" with access to your physcial network?

I'm all for shifting the device pointer down a few bits to get more
entropy, but I don't completely agree with the rest of your
objections.

This hash function has to be as fast as possible, even jhash{,2} is
too expensive.
