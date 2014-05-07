From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: add support for scheduling TCP options on TCP
 sockets
Date: Wed, 07 May 2014 13:24:41 -0400 (EDT)
Message-ID: <20140507.132441.1803688666370582852.davem@davemloft.net>
References: <906b020ccf1b4e1b98ac414147259a65@UCL-MBX03.OASIS.UCLOUVAIN.BE>
	<20140507141108.GG4686@cpaasch-mac>
	<CAE1zot+L0WVdxSRX7gUSU7V52X0qdk2mTrsXaCAbGmPRu6=Yog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, netdev@vger.kernel.org
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbaEGRYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 13:24:43 -0400
In-Reply-To: <CAE1zot+L0WVdxSRX7gUSU7V52X0qdk2mTrsXaCAbGmPRu6=Yog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Wed, 7 May 2014 18:17:08 +0300

> That would require adding a new field to sk_buff to keep track of how
> much we need to copy in pskb_copy. Fortunately it seems it has some
> holes we could use.
> 
> David, does that seem reasonable?

As long as you can find a way to delete something in sk_buff to make
room for it sure.

I am very serious, I don't want sk_buff to turn into something like mm_struct
which seems to double in size every time I look at it.
