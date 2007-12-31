From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [NEIGH] Remove unused method from
 include/net/neighbour.h
Date: Sun, 30 Dec 2007 23:26:31 -0800 (PST)
Message-ID: <20071230.232631.199492951.davem@davemloft.net>
References: <eb3ff54b0712280756m45c92c0bhc1298f6b428ac3ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753194AbXLaH0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 02:26:32 -0500
In-Reply-To: <eb3ff54b0712280756m45c92c0bhc1298f6b428ac3ed@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Fri, 28 Dec 2007 17:56:46 +0200

> It seems to me that neigh_is_valid() inline method from
> include/net/neighbour.h can be removed since it is not used.
> 
> Though it can be considered as an API for future use, and
> indeed we have neigh_is_connected() method in this same header (which is BTW
> used only in one place, drivers/net/cxgb3/l2t.c), we can easily notice
> that we don't have
> any accessor method to check whether the neighbour is in NUD_IN_TIMER
> (not to mention that we don't have methods to check the single neighbour states,
> like NUD_REACHABLE or NUD_DELAY or the other ones). So for consistency
> I suggest to
> consider removing the neigh_is_valid() method.
>
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

This is a helper function which was used by drivers implementing
support for the old fast routing code which we removed years ago.

So yes we should remove this.

Patch applied.
