From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: vlan: 802.1ad S-VLAN support
Date: Mon, 18 Jul 2011 11:37:31 -0700 (PDT)
Message-ID: <20110718.113731.1384541339327086734.davem@davemloft.net>
References: <1310936105-3494206-1-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010Ab1GRSkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 14:40:15 -0400
In-Reply-To: <1310936105-3494206-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Sun, 17 Jul 2011 22:55:05 +0200

>  - int vlan_pidx(u16 protocol)
>    do i do this with a table? that wastes a cacheline... as code it's
>    around 32 bytes on x86_64. it's not called for regular 802.1Q frames
>    from any hot paths btw, so maybe i shouldn't care?

Don't worry about something you haven't seen on profiling output yet,
unless it's something painfully obvious (f.e. using linked list of
thousands of entries for lookups)

FWIW, the counter argument for your concern is that the function
version takes up an I-cache line.

Anyways, like I said, I'd just leave it alone and get rid of all of
that #if 0 stuff.
