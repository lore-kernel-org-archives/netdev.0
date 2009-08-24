From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sit: 6to4: honour routing table
Date: Sun, 23 Aug 2009 19:05:21 -0700 (PDT)
Message-ID: <20090823.190521.44468784.davem@davemloft.net>
References: <1250938072-5577-1-git-send-email-contact@saschahlusiak.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: contact@saschahlusiak.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59066
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751168AbZHXCFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2009 22:05:08 -0400
In-Reply-To: <1250938072-5577-1-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hlusiak <contact@saschahlusiak.de>
Date: Sat, 22 Aug 2009 12:47:52 +0200

> This patch makes try_6to4 use the address of the Next-Hop instead, respecting
> the routing table. Users are encouraged to have a route 2002::/16 to the
> tunnel device anyway, making all other 6to4 hosts direct neighbours.

This doesn't seem right to me at all, but I'm not a complete expert
in this area.

Can someone who is review this patch?  Thanks.
