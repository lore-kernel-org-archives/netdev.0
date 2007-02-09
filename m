From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : change layout of ehash table
Date: Fri, 09 Feb 2007 01:15:42 -0800 (PST)
Message-ID: <20070209.011542.21927454.davem@davemloft.net>
References: <p73zm7n1ygk.fsf@bingen.suse.de>
	<20070209.004019.75431263.davem@davemloft.net>
	<200702091006.24242.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, linux@horizon.com, akepner@sgi.com,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1946244AbXBIJPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 04:15:44 -0500
In-Reply-To: <200702091006.24242.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 9 Feb 2007 10:06:24 +0100

> Yes, but a decent C compiler for such targets should not use a
> multiply instruction to perform a (idx * 12) operation... :)

Good point.

Actually, I could never get GCC to avoid a divide on sparc64 for
certain kinds of pointer arithmetic when the elements were not
a power of two.  It probably has something to do with signedness.

I think I narrowed is down to the fact that you can't legally replace
a signed divide with shift/add/subtract.  But I could be remembering
things wrong.
