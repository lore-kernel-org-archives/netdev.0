From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] rose_route_frame() NULL pointer dereference kernel
 panic
Date: Thu, 03 Mar 2016 17:02:53 -0500 (EST)
Message-ID: <20160303.170253.1102862150292919836.davem@davemloft.net>
References: <56CDDFF7.2040609@free.fr>
	<20160225.170957.836114237953219422.davem@davemloft.net>
	<56D5FD7A.5080104@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org
To: f6bvp@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbcCCWCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 17:02:55 -0500
In-Reply-To: <56D5FD7A.5080104@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: f6bvp <f6bvp@free.fr>
Date: Tue, 1 Mar 2016 21:37:14 +0100

> I built the following patch in order to obtain the same result without
> NULL pointer.

But it will cause every packet to be dropped because rose_route_frame() won't
find a matching neighbour, and therefore return 0 to rose_xmit().
