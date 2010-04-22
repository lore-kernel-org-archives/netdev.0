From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NIU support for skb->rxhash
Date: Thu, 22 Apr 2010 14:37:09 -0700 (PDT)
Message-ID: <20100422.143709.170109603.davem@davemloft.net>
References: <20100422.042157.99869295.davem@davemloft.net>
	<20100422092120.603e83b8@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40006
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751221Ab0DVVhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 17:37:05 -0400
In-Reply-To: <20100422092120.603e83b8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 22 Apr 2010 09:21:20 -0700

> Could you make configurable via ethtool like I did for sky2.

I'd much rather not.

I don't want to have two code different paths, extra conditionals,
etc. here.  And there's no need to really, it's cheap enough.

I think drivers should unconditionally provide ->rxhash if they
reasonably can, otherwide don't bother at all.
