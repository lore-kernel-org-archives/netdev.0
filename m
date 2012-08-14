From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] packet: Sock-diag extension for packet
 sockets (beginning)
Date: Tue, 14 Aug 2012 16:56:59 -0700 (PDT)
Message-ID: <20120814.165659.447574800340205124.davem@davemloft.net>
References: <5029219C.20305@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab2HNX5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 19:57:00 -0400
In-Reply-To: <5029219C.20305@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Mon, 13 Aug 2012 19:47:40 +0400

> There's a set of stuff residing on a AF_PACKET socket which is currently
> write-only -- rings, copy_thresh and mclist. But we need to know these
> while doing the checkpoint-restore.
> 
> As a solution for the similar problem with unix sockets, the sock-diag
> engine was developed, so here's the basic implementation of the packet
> sockets extension. It doesn't report rings, fanout and stats, but it can
> be easily added later.
> 
> I'd like to mention, that it's not a strict requirement, that the diag is
> used for getting info about sockets, it would be perfectly fine just to
> fix the packet getsockopt callback to return the desired info. So, if the
> diag for packet sockets is for any reason unacceptable, just let me know.

All applied, looks fine.

Please number your patches properly next time, patch #3 was listed as 2/4
