From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6:fix the return interface index when get it while
 no message is received
Date: Mon, 18 Aug 2008 22:38:57 -0700 (PDT)
Message-ID: <20080818.223857.125980599.davem@davemloft.net>
References: <48A911AD.7060102@cn.fujitsu.com>
	<48A9799B.4040409@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanghy@cn.fujitsu.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50355
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753301AbYHSFi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 01:38:58 -0400
In-Reply-To: <48A9799B.4040409@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 18 Aug 2008 09:31:07 -0400

> I don't think that's correct at all.  The code path shows here is
> when there are no received options and no sticky options set.  In
> such case, we shouldn't be returning multicast or bound interfaces.
> We should be returning 0.
>
> Additionally the address returned is completely bogus as well.  We
> are returning the address our peer instead of the one of our own
> addresses.

Yang, please fix this up, thank you.
