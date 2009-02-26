From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: don't use tw net when accounting for recycled tw
Date: Thu, 26 Feb 2009 03:35:54 -0800 (PST)
Message-ID: <20090226.033554.143229118.davem@davemloft.net>
References: <49A67DAB.9060203@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55340
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751929AbZBZLgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 06:36:16 -0500
In-Reply-To: <49A67DAB.9060203@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 26 Feb 2009 14:31:55 +0300

> We already have a valid net in that place, but this is not just a
> cleanup - the tw pointer can be NULL there sometimes, thus causing
> an oops in NET_NS=y case.
> 
> The same place in ipv4 code already works correctly using existing 
> net, rather than tw's one.
> 
> The bug exists since 2.6.27.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied and queued up for -stable, thanks!
