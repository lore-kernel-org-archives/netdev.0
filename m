From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Allowing more than 64k bound to zero port connections.
Date: Mon, 22 Dec 2008 19:51:16 -0800 (PST)
Message-ID: <20081222.195116.10343492.davem@davemloft.net>
References: <20081218212549.GA20836@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49246
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753178AbYLWDvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 22:51:15 -0500
In-Reply-To: <20081218212549.GA20836@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Fri, 19 Dec 2008 00:25:49 +0300

> Attached patch allows to remove this limit. Currently inet port
> selection algorithm runs over the whole bind hash table and checks if
> appropriate hash bucket does not use randomly selected port. When it
> found given cell, system binds socket to the selected port. If sockets
> are not freed, this will be finished after local port range is
> exhausted, not even trying to check if bound sockets have reuse socket
> option and thus could share the bucket.

I've reviewed this enough to believe that it is implemented
properly.

However I want to do some research about socket semantics in
this area before applying this.  I'm travelling and don't
have my favorite books with me, so this will have to wait
until later this week.

Thanks.
