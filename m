From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP : keep copied_seq, rcv_wup and rcv_next together
Date: Thu, 22 Feb 2007 02:32:20 -0800 (PST)
Message-ID: <20070222.023220.92577095.davem@davemloft.net>
References: <1171583205.29021.44.camel@localhost>
	<20070222.012649.119274047.davem@davemloft.net>
	<200702221122.02806.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32964
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933004AbXBVKcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 05:32:21 -0500
In-Reply-To: <200702221122.02806.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 22 Feb 2007 11:22:02 +0100

> rcv_wup and copied_seq should be next to rcv_nxt field, to lower number of 
> active cache lines in hot paths. (tcp_rcv_established(), tcp_poll(), ...)

Please fixup the assignment order in tcp_create_openreq_child() else
we'll get a new store buffer stall during socket creation :-)

Thanks Eric.
