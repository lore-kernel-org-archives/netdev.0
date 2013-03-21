From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix psock_fanout selftest hash collision
Date: Wed, 20 Mar 2013 21:16:25 -0400 (EDT)
Message-ID: <20130320.211625.1083595240992829898.davem@davemloft.net>
References: <20130320.123344.1566685302188091721.davem@davemloft.net>
	<20130320.135934.156565403641352244.davem@davemloft.net>
	<CA+FuTScnkvSZ1U=vmELNEpS4hU62iMV7B2ZDHT8KGAwxCxA-Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755Ab3CUBQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 21:16:28 -0400
In-Reply-To: <CA+FuTScnkvSZ1U=vmELNEpS4hU62iMV7B2ZDHT8KGAwxCxA-Ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 20 Mar 2013 20:07:21 -0400

> Come to think of it, is this a 64-bit kernel with 32-bit userland?
> Perhaps that affects packet ring memory layout.

Yes, it is.
