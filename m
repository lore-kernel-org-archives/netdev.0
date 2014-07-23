From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: Fix integer-overflows in TCP vegas
Date: Wed, 23 Jul 2014 14:53:00 -0700 (PDT)
Message-ID: <20140723.145300.680180435593895552.davem@davemloft.net>
References: <1406065017-22102-1-git-send-email-christoph.paasch@uclouvain.be>
	<063D6719AE5E284EB5DD2968C1650D6D1727BEDC@AcuExch.aculab.com>
	<20140723111802.GB6387@cpaasch-mac>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	doug.leith@nuim.ie, ncardwell@google.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933543AbaGWVxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 17:53:01 -0400
In-Reply-To: <20140723111802.GB6387@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: 'Christoph Paasch' <christoph.paasch@uclouvain.be>
Date: Wed, 23 Jul 2014 13:18:02 +0200

> What do you (or others) think?

I think we should avoid the 64-bit operation altogether.

If you can't say for sure whether or not constraints guarantee
no overflows if you code this a certain way, add assertions.
