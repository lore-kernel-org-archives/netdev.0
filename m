From: David Miller <davem@davemloft.net>
Subject: Re: Deadlock with icmpv6fuzz
Date: Mon, 26 Jan 2009 21:31:12 -0800 (PST)
Message-ID: <20090126.213112.197185044.davem@davemloft.net>
References: <20090120204743.GA25797@alice>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: snakebyte@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57655
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750717AbZA0FbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 00:31:14 -0500
In-Reply-To: <20090120204743.GA25797@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Sesterhenn <snakebyte@gmx.de>
Date: Tue, 20 Jan 2009 21:47:43 +0100

> Kernel is current -git

Weird trace.

I can't figure out what would cause it.

Is the program counter on the skb_push() call
that is part of that:

	struct ipv6_opt_hdr *h = (struct ipv6_opt_hdr *)skb_push(skb, ipv6_optlen(opt));

line it seems to be stuck on?

