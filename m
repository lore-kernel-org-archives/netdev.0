From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: add support for scheduling TCP options on TCP
 sockets
Date: Wed, 07 May 2014 13:23:01 -0400 (EDT)
Message-ID: <20140507.132301.170284205486641795.davem@davemloft.net>
References: <20140507134620.GF4686@cpaasch-mac>
	<906b020ccf1b4e1b98ac414147259a65@UCL-MBX03.OASIS.UCLOUVAIN.BE>
	<20140507141108.GG4686@cpaasch-mac>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: octavian.purdila@intel.com, netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaEGRXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 13:23:02 -0400
In-Reply-To: <20140507141108.GG4686@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Wed, 7 May 2014 16:11:08 +0200

> Yes, but it could be done in a more "clean" way so that future
> extensions to TCP are no more limited by the limitation of struct
> tcp_skb_cb.

Would you stop harping on this point?

Adding new options to TCP is a really big deal, it implicitly
involves deeply understanding how it interacts with other options
and what is the most optimal way to insert those options in the
output path.

It should be "hard".
