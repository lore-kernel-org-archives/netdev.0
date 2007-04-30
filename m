From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5 2.6.21-rc7] l2tp: pppol2tp core
Date: Mon, 30 Apr 2007 00:18:48 -0700 (PDT)
Message-ID: <20070430.001848.10298399.davem@davemloft.net>
References: <200704231601.l3NG13TN030167@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47392
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423092AbXD3HSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:18:51 -0400
In-Reply-To: <200704231601.l3NG13TN030167@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Mon, 23 Apr 2007 17:01:03 +0100

> [L2TP]: Add PPP-over-L2TP driver core.
> 
> This driver handles only L2TP data frames; control frames are handled
> by a userspace application. It implements L2TP using the PPPoX socket
> family. Data is sent or received using regular socket sendmsg() /
> recvmsg() calls. Kernel parameters of the socket can be read or
> modified using ioctl() or [gs]etsockopt() calls.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

I have no major objections to this patch.

It is certainly verbose and could stand a lot of cleanup
and debug code removal, but it's functional and has no
glaring abuses of the networking.

Please fixup patch #2 so I can apply this one.

Thanks.
